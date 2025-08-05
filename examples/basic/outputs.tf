# Local environment outputs

# Resource Group outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.xmpro_platform.resource_group_name
}

# Database outputs
output "sql_server_name" {
  description = "The name of the SQL server"
  value       = module.xmpro_platform.sql_server_name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = module.xmpro_platform.sql_server_fqdn
}

# DNS outputs
output "dns_zone_nameservers" {
  description = "The nameservers of the DNS zone"
  value       = module.xmpro_platform.dns_zone_nameservers
}

# App Service URLs
output "ad_app_url" {
  description = "The URL of the App Designer app service"
  value       = module.xmpro_platform.ad_app_url
}

output "ds_app_url" {
  description = "The URL of the Data Stream Designer app service"
  value       = module.xmpro_platform.ds_app_url
}

output "sm_app_url" {
  description = "The URL of the Subscription Manager app service"
  value       = module.xmpro_platform.sm_app_url
}

output "ai_app_url" {
  description = "The URL of the AI app service"
  value       = module.xmpro_platform.ai_app_url
}

# Environment information
output "environment" {
  description = "The environment name"
  value       = var.environment
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "company_details" {
  description = "Details about the company admin"
  value       = module.xmpro_platform.company_details
}

output "evaluation_mode_status" {
  description = "Status of the evaluation mode"
  value       = module.xmpro_platform.evaluation_mode_status
}