# Collection ID and secret are provided by the main module

# Container Group for DS Database Migration
resource "azurerm_container_group" "dsdbmigrate" {
  name                = "ci-${var.company_name}-dsdbmigrate-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public" # Required for container registry access and potential external dependencies
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
    name   = "dsdbmigrate"
    image  = "${var.acr_url_product}/dsdbmigrate:${var.imageversion}"
    cpu    = 0.2
    memory = 0.5

    environment_variables = {
      "DSDB_COLLECTION_NAME"   = var.collection_name
      "DSDB_COLLECTION_ID"     = var.collection_id
      "DSDB_COLLECTION_SECRET" = var.collection_secret
      "DSDB_CONNECTIONSTRING"  = var.db_connection_string
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    "Product"    = "Database Migration Container"
    "CreatedFor" = "DS Database migration and initialization"
    database_id  = substr(var.ds_database_id, 0, 8) # Reference the database ID to establish dependency
  })
}