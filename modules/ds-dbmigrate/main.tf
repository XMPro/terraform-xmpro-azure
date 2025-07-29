# Generate a random UUID for collection ID
resource "random_uuid" "collection_id" {
}

# Generate a random string for collection secret
resource "random_string" "collection_secret" {
  length  = 32
  upper   = true
  lower   = true
  numeric = true
  special = false
}

# Container Group for DS Database Migration
resource "azurerm_container_group" "dsdbmigrate" {
  name                = "cg-${var.company_name}-dsdbmigrate-${var.environment}-${var.deployment_suffix}"
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
    type = "SystemAssigned"
  }

  container {
    name   = "dsdbmigrate"
    image  = "${var.acr_url_product}/dsdbmigrate:${var.imageversion}"
    cpu    = 0.2
    memory = 0.5

    environment_variables = {
      "DSDB_COLLECTION_NAME"   = var.collection_name
      "DSDB_COLLECTION_ID"     = coalesce(var.collection_id != "" ? var.collection_id : null, random_uuid.collection_id.result)
      "DSDB_COLLECTION_SECRET" = coalesce(var.collection_secret != "" ? var.collection_secret : null, random_string.collection_secret.result)
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
  })
}