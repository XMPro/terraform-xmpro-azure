output "zone_ids" {
  description = "Map of DNS zone names to their IDs"
  value = {
    for k, v in azurerm_private_dns_zone.zones : k => v.id
  }
}

output "zone_names" {
  description = "Map of DNS zone keys to their names"
  value = {
    for k, v in azurerm_private_dns_zone.zones : k => v.name
  }
}

output "vnet_link_ids" {
  description = "Map of VNet link names to their IDs"
  value = {
    for k, v in azurerm_private_dns_zone_virtual_network_link.vnet_links : k => v.id
  }
}