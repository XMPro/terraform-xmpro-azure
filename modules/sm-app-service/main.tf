# Key Vault is now managed at the top level for proper module composition

# Create user-assigned managed identity for SM app service
resource "azurerm_user_assigned_identity" "sm_app_identity" {
  name                = "uai-sm-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Local values for standardized naming
locals {
  # Standard app service name: app-<app_name>-<name_suffix>
  app_service_name = substr("app-sm-${var.name_suffix}", 0, 60)

  # Standard app service plan name: plan-<app_name>-<suffix>
  app_service_plan_name = substr("plan-sm-${var.name_suffix}", 0, 40)
}

# Service Plan for SM app
resource "azurerm_service_plan" "app_service_plan" {
  name                = local.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = var.service_plan_sku
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "sm_app_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.sm_app_identity.principal_id

  certificate_permissions = [
    "Get",
    "List",
  ]

  key_permissions = []

  secret_permissions = [
    "Get",
    "List",
  ]

  storage_permissions = []

  depends_on = [azurerm_user_assigned_identity.sm_app_identity]
}

# App service certificate using directly passed PFX blob
resource "azurerm_app_service_certificate" "sm_signing_cert" {
  name                = "SM-SigningCert"
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = azurerm_service_plan.app_service_plan.id
  pfx_blob            = var.certificate_pfx_blob
  tags                = var.tags
}

# Windows Web App for SM
resource "azurerm_windows_web_app" "sm_website" {
  name                = local.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id
  https_only          = true

  site_config {
    websockets_enabled = true
    use_32_bit_worker  = false
    http2_enabled      = true
  }

  app_settings = {
    "WEBSITE_LOAD_CERTIFICATES" = "*"
    "WEBSITE_RUN_FROM_PACKAGE"  = "https://${var.storage_account_name}.file.core.windows.net/${var.files_location}/SM-${var.github_release_version}.zip${var.storage_sas_token}"
    "AZURE_CLIENT_ID"           = azurerm_user_assigned_identity.sm_app_identity.client_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.sm_app_identity.id]
  }

  tags = var.tags
}

# SM deployment is now handled via WEBSITE_RUN_FROM_PACKAGE app setting
# which points directly to the SM.zip file prepared by the sm-prep-container module
