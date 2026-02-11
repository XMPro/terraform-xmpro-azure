# Existing Database Example - Application Outputs

output "ad_app_url" {
  description = "App Designer URL"
  value       = module.applications.ad_app_url
}

output "ds_app_url" {
  description = "Data Stream Designer URL"
  value       = module.applications.ds_app_url
}

output "sm_app_url" {
  description = "Subscription Manager URL"
  value       = module.applications.sm_app_url
}

output "ai_app_url" {
  description = "AI Designer URL"
  value       = module.applications.ai_app_url
}
