# Linux PowerShell Container Instance for SM Zip Preparation
# Replaces SM MSDeploy with a containerized approach for generating deployment packages

# Calculate file hashes and deployment triggers for change detection
locals {
  # Calculate stable file hash to detect script changes
  prepare_script_hash = filesha256("${path.module}/scripts/prepare-sm.ps1")

  # Combined hash for container group triggering - includes release version for proper lifecycle
  scripts_combined_hash = sha256("${local.prepare_script_hash}:${var.release_version}")

  # Container group name using name_suffix for uniqueness (Azure limit is 63 chars)
  container_group_name = format("ci-%s-%s-sm-prep", var.company_name, var.name_suffix)

  # Complete SM.zip download URL
  sm_zip_url = "https://${var.sm_zip_download_url}/${var.release_version}/SM-v${var.release_version}.zip"

  # Determine if we need to create the file share (only if storage_share_id is empty)
  should_create_share = var.storage_share_id == ""

  # Use created share ID if we created it, otherwise use provided ID
  actual_storage_share_id = local.should_create_share ? azurerm_storage_share.sm_prep_share[0].id : var.storage_share_id
}

# Create file share if it doesn't exist (when storage_share_id is empty)
resource "azurerm_storage_share" "sm_prep_share" {
  count                = local.should_create_share ? 1 : 0
  name                 = var.share_name
  storage_account_name = var.storage_account_name
  quota                = 5 # 5 GB quota
}


# Upload main preparation script to storage share
resource "azurerm_storage_share_file" "prepare_script" {
  name             = "prepare-sm.ps1"
  storage_share_id = local.actual_storage_share_id
  source           = "${path.module}/scripts/prepare-sm.ps1"

  # Add content identifier for tracking without triggering recreation
  metadata = {
    content_id        = substr(local.prepare_script_hash, 0, 16)
    terraform_managed = "true"
  }

  # Prevent unnecessary recreation due to MD5 volatility
  lifecycle {
    ignore_changes = [
      content_md5
    ]
  }
}

# Container Group for SM zip preparation
resource "azurerm_container_group" "sm_zip_prep" {
  name                = local.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  restart_policy      = "Never"

  # Image registry credentials for private ACR
  dynamic "image_registry_credential" {
    for_each = var.is_private_registry ? [1] : []
    content {
      server   = var.acr_url_product
      username = var.acr_username
      password = var.acr_password
    }
  }

  # Container definition
  container {
    name   = "sm-zip-prep"
    image  = "${var.acr_url_product}/powershell:latest"
    cpu    = 0.25
    memory = 0.5

    # Command to run PowerShell preparation script
    commands = ["pwsh", "-c", "/scripts/prepare-sm.ps1"]

    # Environment variables for the container
    environment_variables = {
      # SM.zip download and deployment config
      SM_ZIP_DOWNLOAD_URL = local.sm_zip_url
      RELEASE_VERSION     = var.release_version
      DEPLOYMENT_TRIGGER  = "terraform-${substr(local.scripts_combined_hash, 0, 12)}"
      SCRIPTS_HASH        = local.scripts_combined_hash

      # Core config processing flags
      ENABLE_CONFIG_BUILDERS         = "true"
      ENABLE_SECRETS_AZURE_KEY_VAULT = "true"
      ENABLE_SECRETS_AWS             = "false"
      ENABLE_SECRETS_NONE            = "false"

      # Logging configuration
      ENABLE_LOG_FILE_OUTPUT = "true"
      LOG_FILE_PATH          = "D:\\home\\LogFiles\\Application\\sm-log-.txt"

      # Azure Key Vault integration
      AZURE_KEY_VAULT_NAME = var.azure_key_vault_name

      # Required application settings (Key Vault reference format)
      PRODUCT_ID          = "$${ServerUUID}"
      BASE_URL            = "$${DNSName}"
      INTERNAL_BASE_URL   = ""
      TOKEN_CERT_SUBJECT  = "$${CERT}"
      TOKEN_CERT_LOCATION = "CurrentUser"

      # Database settings
      DB_CONNECTION_STRING     = "$${SQLSERVER}"
      ENABLE_DB_MIGRATIONS     = "false"
      INCLUDE_AI_DB_MIGRATIONS = "false"

      # Security settings
      AES_SALT = "$${SALT}"

      # AutoScale settings
      ENABLE_AUTO_SCALE            = "$${AutoScaleEnable}"
      AUTO_SCALE_CONNECTION_STRING = "$${REDIS}"

      # Email settings (Key Vault reference format)
      ENABLE_EMAIL                  = "$${SMTPENABLE}"
      EMAIL_SERVER                  = "$${SMTPSERVER}"
      EMAIL_SERVER_SSL              = "$${SMTPENABLESSL}"
      EMAIL_SERVER_PORT             = "$${SMTPPORT}"
      EMAIL_USE_DEFAULT_CREDENTIALS = "false"
      EMAIL_USERNAME                = "$${SMTPUSER}"
      EMAIL_PASSWORD                = "$${SMTPPASS}"
      EMAIL_FROM_ADDRESS            = "$${SMTPFrom}"
      EMAIL_TEMPLATE_FOLDER         = "~/App_Data/Templates/"
      EMAIL_WEB_APPLICATION         = "true"

      # SSO Configuration (Azure AD) - Use same pattern as SMTP variables with $$
      ENABLE_SSO              = var.sso_enabled ? "true" : "false"
      SSO_AZURE_AD_CLIENT_ID  = var.sso_enabled ? "$${SSO-AZURE-AD-CLIENT-ID}" : ""
      SSO_BUSINESS_ROLE_CLAIM = var.sso_enabled ? "$${SSO-BUSINESS-ROLE-CLAIM}" : ""
      SSO_AZURE_AD_TENANT_ID  = var.sso_enabled ? "$${SSO-AZURE-AD-TENANT-ID}" : ""
      SSO_AZURE_AD_SECRET     = var.sso_enabled ? "$${SSO-AZURE-AD-SECRET}" : ""
    }

    # Secure environment variables
    secure_environment_variables = {
      # No longer need secure environment variables for SSO
    }

    # Mount the Azure file share for scripts and output
    volume {
      name                 = "scripts"
      mount_path           = "/scripts"
      read_only            = true
      share_name           = var.share_name
      storage_account_name = var.storage_account_name
      storage_account_key  = var.storage_account_key
    }

    volume {
      name                 = "output"
      mount_path           = "/output"
      read_only            = false
      share_name           = var.share_name
      storage_account_name = var.storage_account_name
      storage_account_key  = var.storage_account_key
    }

    # Port configuration (not needed for this use case but required)
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  # Resource tags
  tags = merge(var.tags, {
    "Purpose" = "sm-zip-preparation"
  })

  # Ensure scripts are uploaded before container starts
  depends_on = [
    azurerm_storage_share_file.prepare_script
  ]
}