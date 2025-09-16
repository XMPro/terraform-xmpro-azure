# Outputs for Stream Host deployment

output "resource_group_name" {
  description = "The name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].id : module.resource_group[0].id
}

output "stream_host_container_group_id" {
  description = "The ID of the stream host container group"
  value       = module.stream_host.container_group_id
}

output "stream_host_container_group_name" {
  description = "The name of the stream host container group"
  value       = module.stream_host.container_group_name
}

# Monitoring outputs (conditional based on enable_monitoring)

output "app_insights_connection_string" {
  description = "Application Insights connection string for monitoring"
  value       = var.enable_monitoring ? module.monitoring[0].app_insights_connection_string : null
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = var.enable_monitoring ? module.monitoring[0].log_analytics_workspace_id : null
}

# Alerting outputs (conditional based on enable_alerting)

output "action_group_id" {
  description = "The ID of the action group for alerts"
  value       = var.enable_alerting ? module.stream_host_alerting[0].action_group_id : null
}