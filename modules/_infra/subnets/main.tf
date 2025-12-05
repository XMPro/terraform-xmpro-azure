# Azure Subnets Module - Creates multiple subnets with different configurations

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  # Private endpoint configuration
  private_endpoint_network_policies_enabled     = try(each.value.private_endpoint_network_policies_enabled, true)
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)

  # Service endpoints
  service_endpoints = try(each.value.service_endpoints, [])

  # Delegation for App Service/Container Apps
  dynamic "delegation" {
    for_each = try(each.value.delegation, null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}