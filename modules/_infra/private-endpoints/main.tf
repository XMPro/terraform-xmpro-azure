# Private Endpoints Module
# Creates private endpoints for Azure resources in the data subnet

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${each.value.name}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource_name]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${each.value.name}-dns-zone-group"
    private_dns_zone_ids = [each.value.private_dns_zone_id]
  }

  tags = var.tags
}
