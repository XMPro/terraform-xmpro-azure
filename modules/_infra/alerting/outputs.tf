output "action_group_id" {
  description = "The ID of the action group for alerts"
  value       = var.enable_alerting ? azurerm_monitor_action_group.xmpro_alerts.id : null
}

output "action_group_name" {
  description = "The name of the action group for alerts"
  value       = var.enable_alerting ? azurerm_monitor_action_group.xmpro_alerts.name : null
}