# Container Group for AD Database Migration
resource "azurerm_container_group" "addbmigrate" {
  name                = "ci-${var.company_name}-addbmigrate-${var.name_suffix}"
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
    type         = var.user_assigned_identity_id != null ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_identity_id != null ? [var.user_assigned_identity_id] : null
  }

  container {
    name   = "addbmigrate"
    image  = "${var.acr_url_product}/addbmigrate:${var.imageversion}"
    cpu    = "0.2"
    memory = "0.5"

    environment_variables = {
      "ADDB_CONNECTIONSTRING" = var.db_connection_string
      "DS_BASEURL_CLIENT"     = var.ds_url
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    "Product"    = "Database Migration Container"
    "CreatedFor" = "AD Database migration and initialization"
    database_id  = substr(var.ad_database_id, 0, 8) # Reference the database ID to establish dependency
  })
}