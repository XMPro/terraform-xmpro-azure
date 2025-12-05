output "container_group_id" {
  description = "ID of the AAD SQL users container group"
  value       = azurerm_container_group.aad_sql_users.id
}

output "container_group_name" {
  description = "Name of the AAD SQL users container group"
  value       = azurerm_container_group.aad_sql_users.name
}
