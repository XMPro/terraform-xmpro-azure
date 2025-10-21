# Reference existing Key Vault from infrastructure layer
data "azurerm_key_vault" "ad_key_vault" {
  name                = var.ad_key_vault_name
  resource_group_name = var.resource_group_name
}

# Manage secrets in the existing Key Vault
module "ad_secrets" {
  source = "../keyvault-secrets"

  key_vault_name      = var.ad_key_vault_name
  resource_group_name = var.resource_group_name

  secrets = {
    "xmpro--xmsettings--data--connectionString" = var.db_connection_string
    "xmpro--data--connectionString"             = var.db_connection_string
    "xmpro--xmidentity--client--id"             = var.ad_product_id
    "xmpro--xmidentity--client--sharedkey"      = var.ad_product_key
    "ApplicationInsights--ConnectionString"     = var.app_insights_connection_string
    "xmpro--xmnotification--email--password"    = var.smtp_password
    "xmpro--appDesigner--encryptionKey"         = var.ad_encryption_key
  }

  tags = var.tags
}

# Local values for standardized naming
locals {
  # Use custom name if provided, otherwise use standard naming: app-<app_name>-<name_suffix>
  app_service_name = coalesce(var.custom_app_service_name, substr("app-ad-${var.name_suffix}", 0, 60))
  # Use custom name if provided, otherwise use standard naming: id-<app_name>-<name_suffix>
  identity_name = coalesce(var.custom_identity_name, substr("id-ad-${var.name_suffix}", 0, 128))

  # Compute hash of all secret values to force container recreation when secrets change
  # When any secret value changes, this hash changes, triggering app_settings update
  secrets_hash = sha256(join("", [
    var.db_connection_string,
    var.ad_product_id,
    var.ad_product_key,
    var.app_insights_connection_string,
    var.smtp_password,
    var.ad_encryption_key
  ]))
}

# Create user-assigned identity for AD app
resource "azurerm_user_assigned_identity" "ad_identity" {
  name                = local.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# RBAC role assignment for AD identity to read secrets from Key Vault
resource "azurerm_role_assignment" "ad_identity_secrets" {
  scope                = data.azurerm_key_vault.ad_key_vault.id
  role_definition_name = var.keyvault_secrets_reader_role_name
  principal_id         = azurerm_user_assigned_identity.ad_identity.principal_id
}

# Reference existing Service Plan from infrastructure layer
data "azurerm_service_plan" "ad_service_plan" {
  name                = var.ad_service_plan_name
  resource_group_name = var.resource_group_name
}

# Terraform data resource to track secrets hash - forces replacement when hash changes
resource "terraform_data" "ad_secrets_tracker" {
  input = local.secrets_hash
}

# Linux Web App for AD
resource "azurerm_linux_web_app" "ad_app" {
  name                            = local.app_service_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  service_plan_id                 = data.azurerm_service_plan.ad_service_plan.id
  https_only                      = true
  key_vault_reference_identity_id = azurerm_user_assigned_identity.ad_identity.id

  site_config {
    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${var.acr_url_product}"
      docker_registry_username = var.is_private_registry ? var.acr_username : null
      docker_registry_password = var.is_private_registry ? var.acr_password : null
    }

    always_on              = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = var.vnet_route_all_enabled
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ad_identity.id]
  }

  # Ensure Key Vault access is configured before creating the app
  depends_on = [azurerm_role_assignment.ad_identity_secrets]

  # Using Key Vault references for sensitive app settings
  app_settings = merge({
    # Standard environment settings
    "ASPNETCORE_ENVIRONMENT"              = var.aspnetcore_environment
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
    "ASPNETCORE_URLS"                     = "http://+:5000"
    "WEBSITES_PORT"                       = "5000"


    # URLs
    "XM__XMPRO__XMIDENTITY__CLIENT__BASEURL"     = var.ad_url
    "XM__XMPRO__XMIDENTITY__SERVER__BASEURL"     = var.sm_url
    "XMPRO__DATASTREAMDESIGNER__SERVER__BASEURL" = var.ds_url

    # Roles and paths
    "XM__XMPRO__XMSETTINGS__ADMINROLE" = "Administrator"
    "XM__XMPRO__HEALTHCHECKS__CSSPATH" = "/app/ClientApp/dist/en-US/assets/content/styles/healthui.css"

    # Feature flags
    "XM__XMPRO__APPDESIGNER__FEATUREFLAGS__ENABLEAPPLICATIONINSIGHTSTELEMETRY" = tostring(true)
    "XM__XMPRO__APPDESIGNER__FEATUREFLAGS__ENABLEHEALTHCHECKS"                 = tostring(true)
    "XM__XMPRO__APPDESIGNER__FEATUREFLAGS__ENABLELOGGING"                      = tostring(true)
    "XM__XMPRO__APPDESIGNER__FEATUREFLAGS__ENABLESECURITYHEADERS"              = tostring(var.enable_security_headers)

    # Auto-scaling and Redis configuration
    "XM__XMPRO__AUTOSCALE__ENABLED"          = tostring(var.enable_auto_scale)
    "XM__XMPRO__AUTOSCALE__CONNECTIONSTRING" = var.enable_auto_scale ? var.redis_connection_string : ""

    # Health Check URLs Configuration
    "XM__XMPRO__HEALTHCHECKS__URLS__0__URL"     = "${var.sm_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__NAME"    = "Subscription Manager API"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__TAGS__0" = "api"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__URL"     = "${var.ds_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__NAME"    = "Data Stream Designer API"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__TAGS__0" = "api"

    # HealthChecksUI Configuration
    "HEALTHCHECKSUI__HEALTHCHECKS__0__NAME" = "Application Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__0__URI"  = "${var.ad_url}/health"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__NAME" = "Data Stream Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__URI"  = "${var.ds_url}/health"

    # Key Vault references for sensitive values
    "APPLICATIONINSIGHTS__CONNECTIONSTRING"     = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["ApplicationInsights--ConnectionString"]})"
    "XMPRO__XMSETTINGS__DATA__CONNECTIONSTRING" = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--xmsettings--data--connectionString"]})"
    "XMPRO__DATA__CONNECTIONSTRING"             = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--data--connectionString"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__ID"         = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--xmidentity--client--id"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__SHAREDKEY"  = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--xmidentity--client--sharedkey"]})"
    "XMPRO__APPDESIGNER__ENCRYPTIONKEY"         = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--appDesigner--encryptionKey"]})"

    # database migrations feature flag
    "XM__XMPRO__APPDESIGNER__FEATUREFLAGS__DBMIGRATIONSENABLED" = tostring(false)

    # SMTP Configuration
    "XMPRO__XMNOTIFICATION__EMAIL__ENABLE"                = "${var.enable_email_notification}"
    "XMPRO__XMNOTIFICATION__EMAIL__SMTPSERVER"            = "${var.smtp_server}"
    "XMPRO__XMNOTIFICATION__EMAIL__FROMADDRESS"           = "${var.smtp_from_address}"
    "XMPRO__XMNOTIFICATION__EMAIL__USERNAME"              = "${var.smtp_username}"
    "XMPRO__XMNOTIFICATION__EMAIL__PASSWORD"              = "@Microsoft.KeyVault(SecretUri=${module.ad_secrets.secret_versionless_ids["xmpro--xmnotification--email--password"]})"
    "XMPRO__XMNOTIFICATION__EMAIL__PORT"                  = "${var.smtp_port}"
    "XMPRO__XMNOTIFICATION__EMAIL__ENABLESSL"             = "${var.smtp_enable_ssl}"
    "XMPRO__XMNOTIFICATION__EMAIL__USEDEFAULTCREDENTIALS" = "false"
    "XMPRO__XMNOTIFICATION__EMAIL__WEBAPPLICATION"        = "true"
    "XMPRO__XMNOTIFICATION__EMAIL__TEMPLATEFOLDER"        = "Templates"
    },
    # Conditionally add AI health check settings only when AI is enabled
    var.ai_url != "" ? {
      "XM__XMPRO__HEALTHCHECKS__URLS__2__URL"     = "${var.ai_url}/health/ping"
      "XM__XMPRO__HEALTHCHECKS__URLS__2__NAME"    = "XMPro AI API"
      "XM__XMPRO__HEALTHCHECKS__URLS__2__TAGS__0" = "api"
      "HEALTHCHECKSUI__HEALTHCHECKS__2__NAME"     = "XMPro AI"
      "HEALTHCHECKSUI__HEALTHCHECKS__2__URI"      = "${var.ai_url}/health"
    } : {}
  )

  logs {
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  # VNet Integration
  virtual_network_subnet_id = var.virtual_network_subnet_id

  tags = var.tags

  # Force replacement when secrets change to clear Key Vault reference cache
  lifecycle {
    replace_triggered_by = [
      terraform_data.ad_secrets_tracker
    ]
  }
}
