# Key Vault for DS app
module "ds_key_vault" {
  source = "../key-vault"

  name                = format("kv-ds-%s", substr(var.name_suffix, 0, 15))
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = var.tags

  # Secrets for DS app
  secrets = {
    "xmpro--xmsettings--data--connectionString" = {
      value = var.db_connection_string
    },
    "xmpro--data--connectionString" = {
      value = var.db_connection_string
    },
    "xmpro--xmidentity--client--id" = {
      value = var.ds_product_id
    },
    "xmpro--xmidentity--client--sharedkey" = {
      value = var.ds_product_key
    },
    "ApplicationInsights--ConnectionString" = {
      value = var.app_insights_connection_string
    }
  }
}

# Local values for standardized naming
locals {
  # Standard app service name: app-<app_name>-<name_suffix>
  app_service_name = substr("app-ds-${var.name_suffix}", 0, 60)

  # Standard app service plan name: plan-<app_name>-<suffix>
  app_service_plan_name = substr("plan-ds-${var.name_suffix}", 0, 40)
}

# Service Plan for DS app
resource "azurerm_service_plan" "ds_service_plan" {
  name                = local.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.service_plan_sku
  tags                = var.tags
}

# Linux Web App for DS
resource "azurerm_linux_web_app" "ds_app" {
  name                = local.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.ds_service_plan.id
  https_only          = true

  site_config {
    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${var.acr_url_product}"
      docker_registry_username = var.is_private_registry ? var.acr_username : null
      docker_registry_password = var.is_private_registry ? var.acr_password : null
    }

    always_on           = true
    minimum_tls_version = "1.2"
  }

  identity {
    type = "SystemAssigned"
  }

  # Using Key Vault references for sensitive app settings
  app_settings = {
    # Standard environment settings
    "ASPNETCORE_ENVIRONMENT"              = var.aspnetcore_environment
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
    "ASPNETCORE_URLS"                     = "http://+:5000"
    "WEBSITES_PORT"                       = "5000"

    # URLs
    "XM__XMPRO__XMIDENTITY__CLIENT__BASEURL" = var.ds_url
    "XM__XMPRO__XMIDENTITY__SERVER__BASEURL" = var.sm_url
    "XMPRO__APPDESIGNER__SERVER__BASEURL"    = var.ad_url

    # Roles and paths
    "XM__XMPRO__XMSETTINGS__ADMINROLE" = "Administrator"
    "XM__XMPRO__HEALTHCHECKS__CSSPATH" = "/app/ClientApp/dist/en-US/assets/content/styles/healthui.css"

    # Feature flags
    "XM__XMPRO__DATASTREAMDESIGNER__FEATUREFLAGS__ENABLEAPPLICATIONINSIGHTSTELEMETRY" = tostring(true)
    "XM__XMPRO__DATASTREAMDESIGNER__FEATUREFLAGS__ENABLEHEALTHCHECKS"                 = tostring(true)
    "XM__XMPRO__DATASTREAMDESIGNER__FEATUREFLAGS__ENABLELOGGING"                      = tostring(true)
    "XM__XMPRO__DATASTREAMDESIGNER__STREAMHOSTDOWNLOADBASEURL"                        = "https://download.app.xmpro.com/"

    # Health Check URLs Configuration
    "XM__XMPRO__HEALTHCHECKS__URLS__0__URL"     = "${var.sm_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__NAME"    = "Subscription Manager API"
    "XM__XMPRO__HEALTHCHECKS__URLS__0__TAGS__0" = "api"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__URL"     = "${var.ds_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__NAME"    = "Data Stream Designer API"
    "XM__XMPRO__HEALTHCHECKS__URLS__1__TAGS__0" = "api"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__URL"     = "${var.ai_url}/health/ping"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__NAME"    = "XMPro AI API"
    "XM__XMPRO__HEALTHCHECKS__URLS__2__TAGS__0" = "api"

    # HealthChecksUI Configuration
    "HEALTHCHECKSUI__HEALTHCHECKS__0__NAME" = "Application Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__0__URI"  = "${var.ad_url}/health"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__NAME" = "Data Stream Designer"
    "HEALTHCHECKSUI__HEALTHCHECKS__1__URI"  = "${var.ds_url}/health"
    "HEALTHCHECKSUI__HEALTHCHECKS__2__NAME" = "XMPro AI"
    "HEALTHCHECKSUI__HEALTHCHECKS__2__URI"  = "${var.ai_url}/health"

    # Key Vault references for sensitive values
    "APPLICATIONINSIGHTS__CONNECTIONSTRING"     = "@Microsoft.KeyVault(SecretUri=${module.ds_key_vault.secret_ids["ApplicationInsights--ConnectionString"]})"
    "XMPRO__XMSETTINGS__DATA__CONNECTIONSTRING" = "@Microsoft.KeyVault(SecretUri=${module.ds_key_vault.secret_ids["xmpro--xmsettings--data--connectionString"]})"
    "XMPRO__DATA__CONNECTIONSTRING"             = "@Microsoft.KeyVault(SecretUri=${module.ds_key_vault.secret_ids["xmpro--data--connectionString"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__ID"         = "@Microsoft.KeyVault(SecretUri=${module.ds_key_vault.secret_ids["xmpro--xmidentity--client--id"]})"
    "XM__XMPRO__XMIDENTITY__CLIENT__SHAREDKEY"  = "@Microsoft.KeyVault(SecretUri=${module.ds_key_vault.secret_ids["xmpro--xmidentity--client--sharedkey"]})"

    # database migrations feature flag
    "XM__XMPRO__DATASTREAMDESIGNER__FEATUREFLAGS__DBMIGRATIONSENABLED" = false
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

  tags = var.tags
}

# Add access policy for DS app to access Key Vault
resource "azurerm_key_vault_access_policy" "ds_app_policy" {
  key_vault_id = module.ds_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.ds_app.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}
