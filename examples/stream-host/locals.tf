# Local values to handle both resource group scenarios
locals {
  # Determine which resource group to use based on configuration
  resource_group_name     = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].name : module.resource_group[0].name
  resource_group_location = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : module.resource_group[0].location
}