# Linux PowerShell Container Instance for SM Zip Preparation
# Replaces SM MSDeploy with a containerized approach for generating deployment packages

# Calculate file hashes and deployment triggers for change detection
locals {
  # Calculate stable file hash to detect script changes
  prepare_script_hash = filesha256("${path.module}/scripts/prepare-sm.ps1")

  # Combined hash for container group triggering - includes release version for proper lifecycle
  scripts_combined_hash = sha256("${local.prepare_script_hash}:${var.release_version}")

  # Container name includes version hash to ensure recreation on version changes
  container_name_suffix = substr(sha256(var.release_version), 0, 8)

  # Validate container group name length (Azure limit is 63 chars)
  container_group_name = format("aci-%s-%s-sm-prep-%s", var.company_name, var.environment, local.container_name_suffix)

  # Complete SM.zip download URL
  sm_zip_url = "https://${var.sm_zip_download_url}/SM/SM-${var.release_version}.zip"
}


# Upload main preparation script to storage share  
resource "azurerm_storage_share_file" "prepare_script" {
  name             = "prepare-sm.ps1"
  storage_share_id = var.storage_share_id
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

  # Container definition
  container {
    name   = "sm-zip-prep"
    image  = "mcr.microsoft.com/powershell:latest"
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
      ENABLE_AUTO_SCALE = "$${AutoScaleEnable}"

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
    }

    # Secure environment variables (none required for storage account downloads)

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