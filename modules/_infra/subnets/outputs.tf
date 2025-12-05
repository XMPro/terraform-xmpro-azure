output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.subnets : k => v.id
  }
}

output "subnet_names" {
  description = "Map of subnet keys to their actual names"
  value = {
    for k, v in azurerm_subnet.subnets : k => v.name
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    for k, v in azurerm_subnet.subnets : k => v.address_prefixes
  }
}

output "subnets" {
  description = "Complete subnet objects"
  value       = azurerm_subnet.subnets
}