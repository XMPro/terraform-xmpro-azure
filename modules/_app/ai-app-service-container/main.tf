# Reference existing Key Vault from infrastructure layer
data "azurerm_key_vault" "ai_key_vault" {
  name                = var.ai_key_vault_name
  resource_group_name = var.resource_group_name
}

# Manage secrets in the existing Key Vault
module "ai_secrets" {
  source = "../keyvault-secrets"

  key_vault_name      = var.ai_key_vault_name
  resource_group_name = var.resource_group_name

  secrets = {
    "xmpro--xmsettings--data--connectionString" = var.db_connection_string
    "xmpro--data--connectionString"             = var.db_connection_string
    "xmpro--xmidentity--client--id"             = var.ai_product_id
    "xmpro--xmidentity--client--sharedkey"      = var.ai_product_key
    "ApplicationInsights--ConnectionString"     = var.app_insights_connection_string
  }

  tags = var.tags
}

# Local values for standardized naming
locals {
  # Use custom name if provided, otherwise use standard naming: app-<app_name>-<name_suffix>
  app_service_name = coalesce(var.custom_app_service_name, substr("app-ai-${var.name_suffix}", 0, 60))
  # Use custom name if provided, otherwise use standard naming: mi-<app_name>-<name_suffix>
  identity_name = coalesce(var.custom_identity_name, substr("mi-ai-${var.name_suffix}", 0, 128))
  # Standard app service plan name: plan-<app_name>-<suffix>
  app_service_plan_name = substr("plan-ai-${var.name_suffix}", 0, 40)
}

# Create user-assigned identity for AI app
resource "azurerm_user_assigned_identity" "ai_identity" {
  name                = local.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# RBAC role assignment for AI identity to read secrets from Key Vault
resource "azurerm_role_assignment" "ai_identity_secrets" {
  scope                = data.azurerm_key_vault.ai_key_vault.id
  role_definition_name = var.keyvault_secrets_reader_role_name
  principal_id         = azurerm_user_assigned_identity.ai_identity.principal_id
}

# Reference existing Service Plan from infrastructure layer
data "azurerm_service_plan" "ai_service_plan" {
  name                = var.ai_service_plan_name
  resource_group_name = var.resource_group_name
}

# Linux Web App for AI
resource "azurerm_linux_web_app" "ai_app" {
  name                            = local.app_service_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  service_plan_id                 = data.azurerm_service_plan.ai_service_plan.id
  https_only                      = true
  public_network_access_enabled   = var.public_network_access_enabled
  key_vault_reference_identity_id = azurerm_user_assigned_identity.ai_identity.id

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
    identity_ids = [azurerm_user_assigned_identity.ai_identity.id]
  }

  # Ensure Key Vault access is configured before creating the app
  depends_on = [azurerm_role_assignment.ai_identity_secrets]

  # Using Key Vault references for sensitive app settings
  app_settings = {
    # Standard environment settings
    "ASPNETCORE_ENVIRONMENT"              = var.aspnetcore_environment
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
    "ASPNETCORE_URLS"                     = "http://+:5000"
    "WEBSITES_PORT"                       = "5000"


    # Feature flags
    "XM__XMPRO__AI__FEATUREFLAGS__ENABLEAPPLICATIONINSIGHTSTELEMETRY" = tostring(true)
    "XM__XMPRO__AI__FEATUREFLAGS__ENABLEHEALTHCHECKS"                 = tostring(true)
    "XM__XMPRO__AI__FEATUREFLAGS__ENABLELOGGING"                      = tostring(true)
    "XM__XMPRO__AI__FEATUREFLAGS__DBMIGRATIONSENABLED"                = tostring(false)

    # URLs
    "XM__XMPRO__XMIDENTITY__SERVER__BASEURL" = var.sm_url
    "XM__XMPRO__XMIDENTITY__CLIENT__BASEURL" = var.ai_url
    "XM__XMPRO__AI__SERVER__BASEURL"         = var.ai_url

    # Health checks CSS path
    "XM__XMPRO__HEALTHCHECKS__CSSPATH" = "ClientApp/src/assets/content/styles/healthui.css"

    # Health Check URLs Configuration
    "XM__XMPRO__HEALTHCHECKS__URLS__0__URL"     = "${var.sm_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__NAME"    = "Subscription Manager API"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__TAGS__0" = "api"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__URL"     = "${var.ds_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__NAME"    = "Data Stream Designer API"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__TAGS__0" = "api"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__URL"     = "${var.ad_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__NAME"    = "Application Designer API"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__TAGS__0" = "api"

    # HealthChecksUI Configuration
    "HEALTHCHECKSUI__HEALTHCHECKS__0__NAME" = "Application Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__0__URI"  = "${var.ad_url}/health"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__NAME" = "Data Stream Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__URI"  = "${var.ds_url}/health"
    "HEALTHCHECKSUI__HEALTHCHECKS__2__NAME" = "XMPro AI"
    "HEALTHCHECKSUI__HEALTHCHECKS__2__URI"  = "${var.ai_url}/health"

    # Key Vault references for sensitive values
    "APPLICATIONINSIGHTS__CONNECTIONSTRING"     = "@Microsoft.KeyVault(SecretUri=${module.ai_secrets.secret_versionless_ids["ApplicationInsights--ConnectionString"]})"
    "XMPRO__XMSETTINGS__DATA__CONNECTIONSTRING" = "@Microsoft.KeyVault(SecretUri=${module.ai_secrets.secret_versionless_ids["xmpro--xmsettings--data--connectionString"]})"
    "XMPRO__DATA__CONNECTIONSTRING"             = "@Microsoft.KeyVault(SecretUri=${module.ai_secrets.secret_versionless_ids["xmpro--data--connectionString"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__ID"         = "@Microsoft.KeyVault(SecretUri=${module.ai_secrets.secret_versionless_ids["xmpro--xmidentity--client--id"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__SHAREDKEY"  = "@Microsoft.KeyVault(SecretUri=${module.ai_secrets.secret_versionless_ids["xmpro--xmidentity--client--sharedkey"]})"
  }

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

  tags = merge(var.tags, {
    product                  = "XMPro AI"
    createdby                = "devops"
    createdfor               = "XMPro AI application"
    aidbmigrate_container_id = substr(var.aidbmigrate_container_id, 0, 8) # Reference the AI DB migration container ID to establish dependency
  })
}