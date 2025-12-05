# Application Layer Local Variables

locals {
  # Construct ARM resource IDs from managed identity names
  # Format: /subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{name}
  # Uses data.azurerm_client_config.current.subscription_id to get subscription ID automatically
  sm_db_identity_resource_id = var.sm_db_managed_identity_name != null ? "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${var.sm_db_managed_identity_name}" : null
  ad_db_identity_resource_id = var.ad_db_managed_identity_name != null ? "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${var.ad_db_managed_identity_name}" : null
  ds_db_identity_resource_id = var.ds_db_managed_identity_name != null ? "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${var.ds_db_managed_identity_name}" : null
  ai_db_identity_resource_id = var.ai_db_managed_identity_name != null ? "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${var.ai_db_managed_identity_name}" : null

  # Database connection strings (using infrastructure SQL server FQDN)
  sql_server_fqdn = var.use_existing_database ? var.existing_sql_server_fqdn : var.sql_server_fqdn

  # Connection strings - conditional based on authentication mode
  # When AAD auth is enabled, use managed identity (no username/password)
  # When AAD auth is disabled, use SQL authentication (with username/password)
  ad_connection_string = var.enable_sql_aad_auth ? (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ad_database_name};Authentication=Active Directory Default;User Id=${var.ad_db_aad_client_id};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    ) : (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ad_database_name};Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  )

  ds_connection_string = var.enable_sql_aad_auth ? (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ds_database_name};Authentication=Active Directory Default;User Id=${var.ds_db_aad_client_id};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    ) : (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ds_database_name};Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  )

  ai_connection_string = var.enable_sql_aad_auth && var.enable_ai ? (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ai_database_name};Authentication=Active Directory Default;User Id=${var.ai_db_aad_client_id};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    ) : (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.ai_database_name};Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  )

  # SM app service always uses SQL authentication (even when enable_sql_aad_auth = true)
  # .NET Framework-based SM doesn't support Azure AD authentication
  sm_connection_string = "Server=tcp:${local.sql_server_fqdn};persist security info=True;user id=${var.db_admin_username};password=${var.db_admin_password};Initial Catalog=${var.sm_database_name};"

  # SM database migration container uses AAD auth when enabled (like AD/DS migrations)
  # The migration container is .NET Core and supports AAD authentication
  sm_dbmigrate_connection_string = var.enable_sql_aad_auth ? (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${var.sm_database_name};Authentication=Active Directory Default;User Id=${var.sm_db_aad_client_id};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    ) : (
    "Server=tcp:${local.sql_server_fqdn};persist security info=True;user id=${var.db_admin_username};password=${var.db_admin_password};Initial Catalog=${var.sm_database_name};"
  )

  # DNS zone name - use existing or created one
  dns_zone_name = var.enable_custom_domain ? var.dns_zone_name : ""

  # Base URLs for services using simplified naming convention
  # Format: app-<app_name>-<company_name>-<suffix>.azurewebsites.net (or custom name)
  # When custom domain is disabled, use azurewebsites.net URLs (with custom names if provided)
  ad_app_service_name = var.name_ad_app_service != null ? var.name_ad_app_service : "app-ad-${var.company_name}-${var.name_suffix}"
  ds_app_service_name = var.name_ds_app_service != null ? var.name_ds_app_service : "app-ds-${var.company_name}-${var.name_suffix}"
  sm_app_service_name = var.name_sm_app_service != null ? var.name_sm_app_service : "app-sm-${var.company_name}-${var.name_suffix}"
  ai_app_service_name = var.name_ai_app_service != null ? var.name_ai_app_service : "app-ai-${var.company_name}-${var.name_suffix}"

  ad_base_url = var.enable_custom_domain ? "https://ad.${local.dns_zone_name}/" : "https://${lower(local.ad_app_service_name)}.azurewebsites.net"
  ds_base_url = var.enable_custom_domain ? "https://ds.${local.dns_zone_name}/" : "https://${lower(local.ds_app_service_name)}.azurewebsites.net"
  ai_base_url = var.enable_ai ? (var.enable_custom_domain ? "https://ai.${local.dns_zone_name}/" : "https://${lower(local.ai_app_service_name)}.azurewebsites.net") : ""
  nb_base_url = var.enable_custom_domain ? "https://nb.${local.dns_zone_name}/" : "https://nb.example.com"
  sm_base_url = var.enable_custom_domain ? "https://sm.${local.dns_zone_name}/" : "https://${lower(local.sm_app_service_name)}.azurewebsites.net"

  # Collection Details (from random resources)
  ds_collection_id     = random_uuid.ds_collection_id.result
  ds_collection_secret = random_string.ds_collection_secret.result

  # Company Admin Details
  # Convert spaces and hyphens to dots in names for username generation
  normalized_first_name  = lower(replace(replace(trimspace(var.company_admin_first_name), " ", "."), "-", "."))
  normalized_last_name   = lower(replace(replace(trimspace(var.company_admin_last_name), " ", "."), "-", "."))
  company_admin_username = var.company_admin_username != "" ? var.company_admin_username : "${local.normalized_first_name}.${local.normalized_last_name}@${var.company_name}.onxmpro.com"

  # Evaluation Mode Configuration
  # Predefined product IDs and keys for evaluation mode (same as licensing web service)
  evaluation_product_ids = var.is_evaluation_mode ? {
    ad = "fe011f90-5bb6-80ad-b0a2-56300bf3b65d"
    ai = var.enable_ai ? "b7be889b-01d3-4bd2-95c6-511017472ec8" : ""
    ds = "71435803-967a-e9ac-574c-face863f7ec0"
    nb = "3765f34c-ff4e-3cff-e24e-58ac5771d8c5"
    } : {
    ad = length(random_uuid.ad_product_id) > 0 ? random_uuid.ad_product_id[0].result : ""
    ai = var.enable_ai && length(random_uuid.ai_product_id) > 0 ? random_uuid.ai_product_id[0].result : ""
    ds = length(random_uuid.ds_product_id) > 0 ? random_uuid.ds_product_id[0].result : ""
    nb = length(random_uuid.nb_product_id) > 0 ? random_uuid.nb_product_id[0].result : ""
  }

  evaluation_product_keys = var.is_evaluation_mode ? {
    ad = "f27eeb2d-c557-281c-9d4c-fe44cfb74a97"
    ai = var.enable_ai ? "950ca93b-1ad9-514b-4263-4d3f510012e2" : ""
    ds = "f744911d-e8a6-f8fb-9665-61b185845d6a"
    nb = "383526ff-8d3f-5941-4bc8-482ed83152be"
    } : {
    ad = length(random_uuid.ad_product_key) > 0 ? random_uuid.ad_product_key[0].result : ""
    ai = var.enable_ai && length(random_uuid.ai_product_key) > 0 ? random_uuid.ai_product_key[0].result : ""
    ds = length(random_uuid.ds_product_key) > 0 ? random_uuid.ds_product_key[0].result : ""
    nb = length(random_uuid.nb_product_key) > 0 ? random_uuid.nb_product_key[0].result : ""
  }

  # Product ID selection based on evaluation mode and existing database configuration
  effective_ad_product_id = var.use_existing_database ? var.existing_ad_product_id : local.evaluation_product_ids.ad
  effective_ds_product_id = var.use_existing_database ? var.existing_ds_product_id : local.evaluation_product_ids.ds
  effective_ai_product_id = var.use_existing_database ? var.existing_ai_product_id : local.evaluation_product_ids.ai

  effective_ad_product_key = var.use_existing_database ? var.existing_ad_product_key : local.evaluation_product_keys.ad
  effective_ds_product_key = var.use_existing_database ? var.existing_ds_product_key : local.evaluation_product_keys.ds
  effective_ai_product_key = var.use_existing_database ? var.existing_ai_product_key : local.evaluation_product_keys.ai

  effective_sm_product_id = var.use_existing_database ? var.existing_sm_product_id : random_uuid.sm_id.result

  # AD Encryption Key (use provided value or generate)
  effective_ad_encryption_key = var.ad_encryption_key != "" ? var.ad_encryption_key : (
    length(random_string.ad_encryption_key) > 0 ? random_string.ad_encryption_key[0].result : ""
  )
}