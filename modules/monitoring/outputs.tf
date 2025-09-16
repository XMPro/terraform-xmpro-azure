output "log_analytics_workspace_id" {
  description = "The workspace ID (GUID) of the Log Analytics workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].workspace_id : null
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].name : null
}

output "log_analytics_workspace_resource_id" {
  description = "The full resource ID of the Log Analytics workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].id : null
}

output "log_analytics_primary_shared_key" {
  description = "The primary shared key for the Log Analytics workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].primary_shared_key : null
  sensitive   = true
}

output "app_insights_id" {
  description = "The ID of the Application Insights instance"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].id : null
}

output "app_insights_name" {
  description = "The name of the Application Insights instance"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].name : null
}

output "app_insights_connection_string" {
  description = "The connection string for the Application Insights instance"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].connection_string : null
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key for the Application Insights instance"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].instrumentation_key : null
  sensitive   = true
}

output "app_insights_app_id" {
  description = "The App ID of the Application Insights instance"
  value       = var.enable_app_insights ? azurerm_application_insights.this[0].app_id : null
}

