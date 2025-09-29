output "container_group_id" {
  description = "The ID of the container group"
  value       = azurerm_container_group.aidbmigrate.id
}

output "container_group_name" {
  description = "The name of the container group"
  value       = azurerm_container_group.aidbmigrate.name
}

output "container_ip_address" {
  description = "The IP address of the container group"
  value       = azurerm_container_group.aidbmigrate.ip_address
}

output "container_fqdn" {
  description = "The FQDN of the container group"
  value       = azurerm_container_group.aidbmigrate.fqdn
}