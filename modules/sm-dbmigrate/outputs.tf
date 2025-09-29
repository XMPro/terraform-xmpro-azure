output "container_group_id" {
  description = "The ID of the container group"
  value       = azurerm_container_group.smdbmigrate.id
}

output "container_group_name" {
  description = "The name of the container group"
  value       = azurerm_container_group.smdbmigrate.name
}

output "container_ip_address" {
  description = "The IP address of the container group"
  value       = azurerm_container_group.smdbmigrate.ip_address
}

output "container_fqdn" {
  description = "The FQDN of the container group"
  value       = azurerm_container_group.smdbmigrate.fqdn
}

output "sm_product_id" {
  description = "The SM product ID"
  value       = var.sm_product_id
}
