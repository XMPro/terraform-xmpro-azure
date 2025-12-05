# Layered Deployment - Infrastructure Layer
# Uses local module source for development with latest changes
# This allows testing the separated infrastructure layer before publishing
#
# Layer Strategy:
# - Infrastructure: Foundational resources (RG, Storage, SQL, KeyVaults, App Service Plan)
# - Application: Application deployments (AD, DS, SM, AI, Stream Host)
# - Each layer maintains its own state file for independent lifecycle management

module "infrastructure" {
  source = "../../../_infra"

  # Core configuration
  company_name = var.company_name
  name_suffix  = var.name_suffix
  location     = var.location

  # Database configuration
  enable_sql_aad_auth = var.enable_sql_aad_auth
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password

  # Custom database names
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
  create_redis_cache = var.create_redis_cache
  create_masterdata  = var.create_masterdata
  enable_ai          = var.enable_ai

  # DNS
  enable_custom_domain = var.enable_custom_domain
  dns_zone_name        = var.dns_zone_name

  # Database configuration
  db_sku_name                  = var.db_sku_name
  db_allow_all_ips             = var.db_allow_all_ips
  create_local_firewall_rule   = var.create_local_firewall_rule
  masterdata_db_admin_username = var.masterdata_db_admin_username
  masterdata_db_admin_password = var.masterdata_db_admin_password

  # Networking configuration
  prod_networking_enabled = var.prod_networking_enabled
  vnet_address_space      = var.vnet_address_space
  subnet_address_prefixes = var.subnet_address_prefixes

  # RBAC configuration
  enable_rbac_authorization = var.enable_rbac_authorization
  keyvault_admin_role_name  = var.keyvault_admin_role_name

  tags = merge(var.tags, {
    Layer = "Infrastructure"
  })
}