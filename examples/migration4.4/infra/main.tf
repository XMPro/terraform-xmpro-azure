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

  # Stream Connector
  enable_stream_connector   = var.enable_stream_connector
  use_existing_mqtt_broker  = var.use_existing_mqtt_broker
  existing_mqtt_broker_fqdn = var.existing_mqtt_broker_fqdn
  existing_mqtt_user        = var.existing_mqtt_user
  existing_mqtt_password    = var.existing_mqtt_password
  mqtt_enable_tls           = var.mqtt_enable_tls

  # Existing-database mode: skip new SQL server provisioning; the app layer
  # will point at the existing server. The _infra module's outputs handle
  # the use_existing_database=true case (sql_server_fqdn returns var.existing_sql_server_fqdn).
  use_existing_database    = var.use_existing_database
  existing_sql_server_fqdn = var.existing_sql_server_fqdn

  tags = merge(var.tags, {
    Layer = "Infrastructure"
  })
}

# Extra CNAME records in the custom DNS zone (e.g. legacy XMTwin helper hosts
# like mlflow / mqtt / neo4j that aren't modelled by the rest of the module).
# Only created when enable_custom_domain = true so we don't try to write into
# a non-existent zone.
resource "azurerm_dns_cname_record" "additional" {
  for_each = var.enable_custom_domain ? var.additional_dns_cname_records : {}

  name = each.key
  # Reference the module's dns_zone_name output (not var.dns_zone_name) so
  # terraform waits for the zone to exist before writing CNAMEs into it.
  zone_name           = module.infrastructure.dns_zone_name
  resource_group_name = module.infrastructure.resource_group_name
  ttl                 = 3600
  record              = each.value

  tags = merge(var.tags, {
    Layer = "Infrastructure"
  })
}

# NS record sets for subdomain delegation in the custom DNS zone (e.g. delegating
# otel.twin.xmpro.com to its own Azure DNS zone's nameservers).
resource "azurerm_dns_ns_record" "additional" {
  for_each = var.enable_custom_domain ? var.additional_dns_ns_records : {}

  name                = each.key
  zone_name           = module.infrastructure.dns_zone_name
  resource_group_name = module.infrastructure.resource_group_name
  ttl                 = 3600
  records             = each.value

  tags = merge(var.tags, {
    Layer = "Infrastructure"
  })
}
