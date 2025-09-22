# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

# Environment outputs
output "environment" {
  description = "The environment name"
  value       = var.environment
}

output "location" {
  description = "The Azure location"
  value       = var.location
}

# Database outputs
output "sql_server_name" {
  description = "The name of the SQL server"
  value       = local.sql_server_name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = local.sql_server_fqdn
}

# DNS outputs
output "dns_zone_nameservers" {
  description = "The nameservers of the DNS zone"
  value       = var.enable_custom_domain ? module.dns_zone[0].name_servers : []
}

output "dns_zone_name" {
  description = "The name of the DNS zone"
  value       = var.enable_custom_domain ? module.dns_zone[0].name : ""
}

output "platform_domain" {
  description = "The platform domain being used for the deployment"
  value       = var.enable_custom_domain ? local.dns_zone_name : "${var.company_name}-${local.name_suffix}.azurewebsites.net"
}

# App Service outputs
output "ad_app_url" {
  description = "The URL of the AD app service"
  value       = local.ad_base_url
}

output "ds_app_url" {
  description = "The URL of the DS app service"
  value       = local.ds_base_url
}

output "sm_app_url" {
  description = "The URL of the SM app service"
  value       = local.sm_base_url
}

output "ai_app_url" {
  description = "The URL of the AI app service"
  value       = var.enable_ai ? (var.enable_custom_domain ? local.ai_base_url : module.ai_app_service[0].app_url) : ""
}

# Stream Host outputs
output "stream_host_container_id" {
  description = "The ID of the stream host container group"
  value       = module.stream_host_container.container_group_id
}

# Company Admin outputs
output "company_details" {
  description = "Details about the company admin"
  value = {
    company_name = var.is_evaluation_mode ? "Evaluation" : var.company_name
    first_name   = var.company_admin_first_name
    last_name    = var.company_admin_last_name
    email        = var.company_admin_email_address
    username     = local.company_admin_username
  }
}

# Existing Database Configuration Warnings
# Redis Cache outputs
output "redis_hostname" {
  description = "The hostname of the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_hostname : null
}

output "redis_port" {
  description = "The SSL port of the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_port : null
}

output "redis_primary_connection_string" {
  description = "The primary connection string for the Redis cache"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_primary_connection_string : null
  sensitive   = true
}

output "redis_configuration" {
  description = "The Redis cache configuration"
  value       = var.create_redis_cache ? module.redis_cache[0].redis_configuration : null
}

output "existing_database_firewall_warning" {
  description = "Warning about firewall rules when using existing database"
  value       = var.use_existing_database ? "WARNING: When using an existing database, ensure that the SQL Server firewall rules allow connections from the newly created Azure resources (App Services, Container Instances). The following resources may need database access: ${module.resource_group.name} resource group containing AD, DS, SM App Services and associated Container Instances." : null
}

output "existing_database_migration_warning" {
  description = "Warning about database migration compatibility when using existing database"
  value       = var.use_existing_database ? "WARNING: Database migrations may fail if the existing database values do not match the configured variables. Ensure the following variables match your existing database setup: company_name='${var.company_name}', ad_product_id='${local.effective_ad_product_id}', ds_product_id='${local.effective_ds_product_id}', license_api_url='${var.license_api_url}', database_names={AD, DS, SM=, and all product URLs (ad_url, ds_url, sm_url, ai_url). Migration containers (sm-dbmigrate, ad-dbmigrate, ds-dbmigrate) are skipped when use_existing_database=true." : null
}

# Evaluation Mode outputs
output "evaluation_mode_status" {
  description = "Status of evaluation mode deployment"
  value = {
    is_evaluation_mode          = var.is_evaluation_mode
    licenses_container_deployed = var.is_evaluation_mode ? true : false
    effective_ad_product_id     = local.effective_ad_product_id
    effective_ds_product_id     = local.effective_ds_product_id
  }
}

# Master Data outputs
output "masterdata_sql_server_name" {
  description = "The name of the Master Data SQL server (if created)"
  value       = var.create_masterdata ? module.masterdata_database[0].sql_server_name : ""
}

output "masterdata_sql_server_fqdn" {
  description = "The FQDN of the Master Data SQL server (if created)"
  value       = local.masterdata_sql_server_fqdn
}

output "masterdata_connection_string" {
  description = "Connection string for the Master Data database (if created)"
  value       = local.masterdata_connection_string
  sensitive   = true
}

output "masterdata_database_created" {
  description = "Whether the Master Data database was created"
  value       = var.create_masterdata
}