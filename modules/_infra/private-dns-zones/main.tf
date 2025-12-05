# Azure Private DNS Zones Module

# Create private DNS zones
resource "azurerm_private_dns_zone" "zones" {
  for_each = var.dns_zones

  name                = each.value.name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link DNS zones to virtual network
# Only create if virtual_network_id is provided
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each = var.dns_zones

  name                  = "link-${each.key}-vnet"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.enable_auto_registration

  tags = var.tags

  # Lifecycle rule to handle the dynamic virtual_network_id
  lifecycle {
    create_before_destroy = true
  }
}