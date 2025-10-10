# Infrastructure Layer Local Variables

locals {
  # Centralized tag management - merges user-provided tags with standard computed tags
  common_tags = merge(var.tags, {
    "Company" = var.company_name
    "Layer"   = "Infrastructure"
  })

  # Database server FQDN calculation
  sql_server_fqdn = var.use_existing_database ? var.existing_sql_server_fqdn : try(module.database[0].sql_server_fqdn, "")

  # Master Data server FQDN (separate server)
  masterdata_sql_server_fqdn = var.create_masterdata ? module.masterdata_database[0].sql_server_fqdn : ""

  # DNS zone name - use created zone
  dns_zone_name = var.enable_custom_domain ? try(module.dns_zone[0].name, "") : ""

  # Base URLs for services using simplified naming convention
  sm_base_url = var.enable_custom_domain ? "https://sm.${local.dns_zone_name}/" : "https://app-sm-${var.company_name}-${var.name_suffix}.azurewebsites.net"
}