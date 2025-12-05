# Application Layer Outputs

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
  value       = var.enable_ai ? local.ai_base_url : ""
}

# Stream Host outputs
output "stream_host_container_id" {
  description = "The ID of the stream host container group"
  value       = length(module.stream_host_container) > 0 ? module.stream_host_container[0].container_group_id : ""
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

# Collection outputs
output "ds_collection_id" {
  description = "DS Collection ID"
  value       = local.ds_collection_id
}

output "ds_collection_secret" {
  description = "DS Collection Secret"
  value       = local.ds_collection_secret
  sensitive   = true
}

# Platform domain output
output "platform_domain" {
  description = "The platform domain being used for the deployment"
  value       = var.enable_custom_domain ? local.dns_zone_name : "${var.company_name}-${var.name_suffix}.azurewebsites.net"
}