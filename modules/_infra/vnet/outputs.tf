output "id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.main.address_space
}

output "location" {
  description = "The location of the virtual network"
  value       = azurerm_virtual_network.main.location
}

output "resource_group_name" {
  description = "The resource group name of the virtual network"
  value       = azurerm_virtual_network.main.resource_group_name
}