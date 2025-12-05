# Azure Network Security Groups Module

# Create NSGs
resource "azurerm_network_security_group" "nsgs" {
  for_each = var.nsgs

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Create NSG rules
resource "azurerm_network_security_rule" "rules" {
  for_each = {
    for rule in flatten([
      for nsg_key, nsg in var.nsgs : [
        for idx, rule in nsg.rules : {
          key                        = "${nsg_key}-${idx}"
          nsg_name                   = azurerm_network_security_group.nsgs[nsg_key].name
          name                       = rule.name
          priority                   = rule.priority
          direction                  = rule.direction
          access                     = rule.access
          protocol                   = rule.protocol
          source_port_range          = rule.source_port_range
          destination_port_range     = rule.destination_port_range
          source_address_prefix      = rule.source_address_prefix
          destination_address_prefix = rule.destination_address_prefix
        }
      ]
    ]) : rule.key => rule
  }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.nsg_name
}