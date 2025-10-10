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
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password

  # App Service Plans
  ad_service_plan_sku           = var.ad_service_plan_sku
  ds_service_plan_sku           = var.ds_service_plan_sku
  sm_service_plan_sku           = var.sm_service_plan_sku
  ai_service_plan_sku           = var.ai_service_plan_sku
  app_service_plan_worker_count = var.app_service_plan_worker_count

  # Features
  create_redis_cache   = var.create_redis_cache
  create_masterdata    = var.create_masterdata
  enable_ai            = var.enable_ai

  # DNS
  enable_custom_domain = var.enable_custom_domain
  dns_zone_name        = var.dns_zone_name

  # Database configuration
  db_sku_name                       = var.db_sku_name
  masterdata_db_admin_username      = var.masterdata_db_admin_username
  masterdata_db_admin_password      = var.masterdata_db_admin_password


  tags = merge(var.tags, {
    Layer = "Infrastructure"
  })
}