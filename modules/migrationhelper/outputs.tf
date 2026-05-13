output "container_group_id" {
  description = "The ID of the migration helper container group"
  value       = azurerm_container_group.migration.id
}

output "container_group_name" {
  description = "The name of the migration helper container group"
  value       = azurerm_container_group.migration.name
}
