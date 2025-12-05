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

# Data source to reference existing identity (when provided from infrastructure layer)
data "azurerm_user_assigned_identity" "existing" {
  count               = var.existing_identity_id != null ? 1 : 0
  name                = split("/", var.existing_identity_id)[8] # Extract identity name from resource ID
  resource_group_name = var.resource_group_name
}

# Local values for standardized naming
locals {
  # Use custom name if provided, otherwise use standard naming: app-<app_name>-<name_suffix>
  app_service_name = coalesce(var.custom_app_service_name, substr("app-sm-${var.name_suffix}", 0, 60))
  # Use custom name if provided, otherwise use standard naming for identity
  identity_name = coalesce(var.custom_identity_name, "uai-sm-${var.name_suffix}")

  # NEW PATTERN: KV + DB identities (when both are provided)
  # OLD PATTERN: Single existing or created identity (for backwards compatibility)
  using_new_pattern = var.kv_identity_id != null && var.kv_identity_client_id != null

  # NEW PATTERN: KV + DB identities (when both provided)
  # OLD PATTERN: Single existing or created identity (backwards compatibility)
  identity_ids = local.using_new_pattern ? compact([
    var.kv_identity_id, # Key Vault access
    var.db_identity_id  # Database AAD authentication (optional)
    ]) : [
    var.existing_identity_id != null ? var.existing_identity_id : azurerm_user_assigned_identity.sm_app_identity[0].id
  ]

  # AZURE_CLIENT_ID app setting - specifies identity for Key Vault access
  kv_client_id = local.using_new_pattern ? var.kv_identity_client_id : (
    var.existing_identity_client_id != null ? var.existing_identity_client_id : azurerm_user_assigned_identity.sm_app_identity[0].client_id
  )

  # Principal ID for RBAC assignments to Key Vault
  kv_principal_id = local.using_new_pattern ? var.kv_identity_principal_id : (
    var.existing_identity_id != null ? data.azurerm_user_assigned_identity.existing[0].principal_id : azurerm_user_assigned_identity.sm_app_identity[0].principal_id
  )
}

# Legacy identity - only created for backwards compatibility
# Not created when using KV+DB pattern or when existing_identity_id provided
resource "azurerm_user_assigned_identity" "sm_app_identity" {
  count               = var.create_identity && var.existing_identity_id == null ? 1 : 0
  name                = local.identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}


# RBAC role assignment for KV identity to read secrets from Key Vault
# Only created when RBAC authorization is enabled
resource "azurerm_role_assignment" "sm_identity_secrets" {
  count                = var.enable_rbac_authorization ? 1 : 0
  scope                = data.azurerm_key_vault.sm_key_vault.id
  role_definition_name = var.keyvault_secrets_reader_role_name
  principal_id         = local.kv_principal_id
}

# RBAC role assignment for KV identity to read certificates from Key Vault
# Only created when RBAC authorization is enabled
resource "azurerm_role_assignment" "sm_identity_certificates" {
  count                = var.enable_rbac_authorization ? 1 : 0
  scope                = data.azurerm_key_vault.sm_key_vault.id
  role_definition_name = var.keyvault_certificates_reader_role_name
  principal_id         = local.kv_principal_id
}

# Access policy for KV identity to read secrets and certificates from Key Vault
# Only created when RBAC authorization is disabled
resource "azurerm_key_vault_access_policy" "sm_identity" {
  count        = var.enable_rbac_authorization ? 0 : 1
  key_vault_id = data.azurerm_key_vault.sm_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = local.kv_principal_id

  secret_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Get", "List"
  ]
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
  name                          = local.app_service_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = data.azurerm_service_plan.sm_service_plan.id
  https_only                    = true
  public_network_access_enabled = var.public_network_access_enabled

  site_config {
    websockets_enabled     = true
    use_32_bit_worker      = false
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    vnet_route_all_enabled = var.vnet_route_all_enabled
  }

  app_settings = {
    "WEBSITE_LOAD_CERTIFICATES" = "*"
    "WEBSITE_RUN_FROM_PACKAGE"  = "https://${var.storage_account_name}.file.core.windows.net/${var.files_location}/SM-${var.github_release_version}.zip${var.storage_sas_token}"
    "AZURE_CLIENT_ID"           = local.kv_client_id # Use KV identity for Key Vault access
  }

  identity {
    type         = "UserAssigned"
    identity_ids = local.identity_ids # KV identity (always) + DB identity (optional)
  }

  # VNet Integration
  virtual_network_subnet_id = var.virtual_network_subnet_id

  tags = var.tags
}

# SM deployment is now handled via WEBSITE_RUN_FROM_PACKAGE app setting
# which points directly to the SM.zip file prepared by the sm-prep-container module
