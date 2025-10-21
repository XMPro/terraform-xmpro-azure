# Container Group for AI Database Migration
resource "azurerm_container_group" "aidbmigrate" {
  name                = "ci-${var.company_name}-aidbmigrate-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never" # Container will not restart automatically

  # Only include image registry credentials for private registries
  dynamic "image_registry_credential" {
    for_each = var.is_private_registry ? [1] : []
    content {
      server   = var.acr_url_product
      username = var.acr_username
      password = var.acr_password
    }
  }

  identity {
    type = "SystemAssigned"
  }

  container {
    name   = "aidbmigrate"
    image  = "${var.acr_url_product}/aidbmigrate:${var.imageversion}"
    cpu    = 0.2
    memory = 0.5

    environment_variables = {
      "AIDB_CONNECTIONSTRING" = var.db_connection_string
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    "Product"    = "Database Migration Container"
    "CreatedFor" = "AI Database migration and initialization"
    database_id  = substr(var.ai_database_id, 0, 8) # Reference the database ID to establish dependency
  })
}