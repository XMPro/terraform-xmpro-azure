output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value = {
    for k, v in azurerm_network_security_group.nsgs : k => v.id
  }
}

output "nsg_names" {
  description = "Map of NSG keys to their names"
  value = {
    for k, v in azurerm_network_security_group.nsgs : k => v.name
  }
}

output "nsgs" {
  description = "Complete NSG objects"
  value       = azurerm_network_security_group.nsgs
}