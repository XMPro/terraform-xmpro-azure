# Local variables for use throughout the configuration
locals {
  # Generate consistent name suffix for this deployment (adopting sandbox-sm-only approach)
  name_suffix = random_id.suffix.hex

  # Centralized tag management - merges user-provided tags with standard computed tags
  common_tags = merge(var.tags, {
    "Environment" = var.environment
    "Company"     = var.company_name
  })
  # Database connection strings
  sql_server_fqdn      = var.use_existing_database ? var.existing_sql_server_fqdn : module.database[0].sql_server_fqdn
  ad_connection_string = "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=AD;Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  ds_connection_string = "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=DS;Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  ai_connection_string = "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=AI;Persist Security Info=False;User ID=${var.db_admin_username};Password=${var.db_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sm_connection_string = "Server=tcp:${local.sql_server_fqdn};persist security info=True;user id=${var.db_admin_username};password=${var.db_admin_password};Initial Catalog=SM;"

  # DNS zone name - use existing or created one
  dns_zone_name = var.enable_custom_domain ? (var.use_existing_dns_zone ? var.dns_zone_name : try(module.dns_zone[0].name, "")) : ""

  # Base URLs for services using simplified naming convention
  # Format: app-<app_name>-<company_name>-<suffix>.azurewebsites.net
  # When custom domain is disabled, use standardized azurewebsites.net URLs
  ad_base_url = var.enable_custom_domain ? "https://ad.${local.dns_zone_name}/" : "https://app-ad-${var.company_name}-${local.name_suffix}.azurewebsites.net"
  ds_base_url = var.enable_custom_domain ? "https://ds.${local.dns_zone_name}/" : "https://app-ds-${var.company_name}-${local.name_suffix}.azurewebsites.net"
  ai_base_url = var.enable_ai ? (var.enable_custom_domain ? "https://ai.${local.dns_zone_name}/" : "https://app-ai-${var.company_name}-${local.name_suffix}.azurewebsites.net") : ""
  nb_base_url = var.enable_custom_domain ? "https://nb.${local.dns_zone_name}/" : "https://nb.example.com"
  sm_base_url = var.enable_custom_domain ? "https://sm.${local.dns_zone_name}/" : "https://app-sm-${var.company_name}-${local.name_suffix}.azurewebsites.net"

  # Collection Details (from consolidated randoms.tf)
  ds_collection_id     = random_uuid.ds_collection_id.result
  ds_collection_secret = random_string.ds_collection_secret.result

  # Company Admin Details
  company_admin_username = var.company_admin_username != "" ? var.company_admin_username : "${var.company_admin_first_name}.${var.company_admin_last_name}@${var.company_name}.onxmpro.com"

  sql_server_name = var.use_existing_database ? split(".", local.sql_server_fqdn)[0] : module.database[0].sql_server_name

  # Evaluation Mode Configuration
  # Predefined product IDs and keys for evaluation mode (same as licensing web service)
  evaluation_product_ids = var.is_evaluation_mode ? {
    ad = "fe011f90-5bb6-80ad-b0a2-56300bf3b65d"
    ai = var.enable_ai ? "b7be889b-01d3-4bd2-95c6-511017472ec8" : ""
    ds = "71435803-967a-e9ac-574c-face863f7ec0"
    nb = "3765f34c-ff4e-3cff-e24e-58ac5771d8c5"
    } : {
    ad = random_uuid.ad_product_id[0].result
    ai = var.enable_ai ? random_uuid.ai_product_id[0].result : ""
    ds = random_uuid.ds_product_id[0].result
    nb = random_uuid.nb_product_id[0].result
  }

  evaluation_product_keys = var.is_evaluation_mode ? {
    ad = "f27eeb2d-c557-281c-9d4c-fe44cfb74a97"
    ai = var.enable_ai ? "950ca93b-1ad9-514b-4263-4d3f510012e2" : ""
    ds = "f744911d-e8a6-f8fb-9665-61b185845d6a"
    nb = "383526ff-8d3f-5941-4bc8-482ed83152be"
    } : {
    ad = random_uuid.ad_product_key[0].result
    ai = var.enable_ai ? random_uuid.ai_product_key[0].result : ""
    ds = random_uuid.ds_product_key[0].result
    nb = random_uuid.nb_product_key[0].result
  }

  # Product ID selection based on evaluation mode
  effective_ad_product_id = var.use_existing_database ? var.existing_ad_product_id : local.evaluation_product_ids.ad
  effective_ds_product_id = var.use_existing_database ? var.existing_ds_product_id : local.evaluation_product_ids.ds
  effective_ai_product_id = var.use_existing_database ? var.existing_ai_product_id : local.evaluation_product_ids.ai

  effective_ad_product_key = var.use_existing_database ? var.existing_ad_product_key : local.evaluation_product_keys.ad
  effective_ds_product_key = var.use_existing_database ? var.existing_ds_product_key : local.evaluation_product_keys.ds
  effective_ai_product_key = var.use_existing_database ? var.existing_ai_product_key : local.evaluation_product_keys.ai

  effective_sm_product_id = var.use_existing_database ? var.existing_sm_product_id : random_uuid.sm_id.result

}