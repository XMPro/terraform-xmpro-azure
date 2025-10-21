output "container_group_id" {
  description = "The ID of the DS database migration container group"
  value       = azurerm_container_group.dsdbmigrate.id
}

output "container_group_name" {
  description = "The name of the DS database migration container group"
  value       = azurerm_container_group.dsdbmigrate.name
}

output "collection_id" {
  description = "The collection ID used for DS database migration"
  value       = var.collection_id
}
output "collection_secret" {
  description = "The collection secret used for DS database migration"
  value       = var.collection_secret
}