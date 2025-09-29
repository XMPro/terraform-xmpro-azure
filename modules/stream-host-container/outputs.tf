output "container_group_id" {
  description = "The ID of the stream host container group"
  value       = azurerm_container_group.stream_host.id
}

output "container_group_name" {
  description = "The name of the stream host container group"
  value       = azurerm_container_group.stream_host.name
}