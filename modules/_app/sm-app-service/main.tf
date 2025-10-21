# Get existing Key Vault from infrastructure
data "azurerm_key_vault" "sm_key_vault" {
  name                = var.sm_key_vault_name
  resource_group_name = var.resource_group_name
}

# Get existing Service Plan from infrastructure
data "azurerm_service_plan" "sm_service_plan" {
  name                = var.sm_service_plan_name
  resource_group_name = var.resource_group_name
}

# Local values for standardized naming
locals {
  # Use custom name if provided, otherwise use standard naming: app-<app_name>-<name_suffix>
  app_service_name = coalesce(var.custom_app_service_name, substr("app-sm-${var.name_suffix}", 0, 60))
  # Use custom name if provided, otherwise use standard naming for identity
  identity_name = coalesce(var.custom_identity_name, "uai-sm-${var.name_suffix}")
}

# Create user-assigned managed identity for SM app service
resource "azurerm_user_assigned_identity" "sm_app_identity" {
  name                = local.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}


# RBAC role assignment for SM identity to read secrets from Key Vault
resource "azurerm_role_assignment" "sm_identity_secrets" {
  scope                = data.azurerm_key_vault.sm_key_vault.id
  role_definition_name = var.keyvault_secrets_reader_role_name
  principal_id         = azurerm_user_assigned_identity.sm_app_identity.principal_id
}

# RBAC role assignment for SM identity to read certificates from Key Vault
resource "azurerm_role_assignment" "sm_identity_certificates" {
  scope                = data.azurerm_key_vault.sm_key_vault.id
  role_definition_name = var.keyvault_certificates_reader_role_name
  principal_id         = azurerm_user_assigned_identity.sm_app_identity.principal_id
}

# App service certificate using directly passed PFX blob
resource "azurerm_app_service_certificate" "sm_signing_cert" {
  name                = "SM-SigningCert"
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = data.azurerm_service_plan.sm_service_plan.id
  pfx_blob            = var.certificate_pfx_blob
  tags                = var.tags
}

# Windows Web App for SM
resource "azurerm_windows_web_app" "sm_website" {
  name                = local.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = data.azurerm_service_plan.sm_service_plan.id
  https_only          = true

  site_config {
    websockets_enabled     = true
    use_32_bit_worker      = false
    http2_enabled          = true
    vnet_route_all_enabled = var.vnet_route_all_enabled
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

  # VNet Integration
  virtual_network_subnet_id = var.virtual_network_subnet_id

  tags = var.tags
}

# SM deployment is now handled via WEBSITE_RUN_FROM_PACKAGE app setting
# which points directly to the SM.zip file prepared by the sm-prep-container module
