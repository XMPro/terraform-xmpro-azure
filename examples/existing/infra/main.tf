# Existing Database Example - Infrastructure Layer
# Use this when connecting to an existing SQL Server and databases
#
# This example creates all infrastructure EXCEPT SQL Server and databases:
# - Resource Group
# - App Service Plans (AD, DS, SM, AI)
# - Key Vaults (AD, DS, SM, AI)
# - Storage Account
# - Monitoring (App Insights, Log Analytics)

module "infrastructure" {
  source = "../../_infra"

  # Core configuration
  company_name = var.company_name
  name_suffix  = var.name_suffix
  location     = var.location

  # Existing database configuration
  use_existing_database    = true
  existing_sql_server_fqdn = var.existing_sql_server_fqdn
  existing_sm_product_id   = var.existing_sm_product_id

  # Database credentials (for connection strings)
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password

  # Custom database names (must match existing)
  sm_database_name = var.sm_database_name
  ad_database_name = var.ad_database_name
  ds_database_name = var.ds_database_name
  ai_database_name = var.ai_database_name

  # App Service Plans
  ad_service_plan_sku           = var.ad_service_plan_sku
  ds_service_plan_sku           = var.ds_service_plan_sku
  sm_service_plan_sku           = var.sm_service_plan_sku
  ai_service_plan_sku           = var.ai_service_plan_sku
  app_service_plan_worker_count = var.app_service_plan_worker_count

  # Features
  enable_ai          = var.enable_ai
  create_redis_cache = var.create_redis_cache

  # DNS (optional)
  enable_custom_domain = var.enable_custom_domain
  dns_zone_name        = var.dns_zone_name

  # Networking (optional)
  prod_networking_enabled = var.prod_networking_enabled
  vnet_address_space      = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes

  # RBAC
  enable_rbac_authorization = var.enable_rbac_authorization
  keyvault_admin_role_name  = var.keyvault_admin_role_name

  tags = var.tags
}
