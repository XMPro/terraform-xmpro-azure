# Container Group for XMPro Licenses
resource "azurerm_container_group" "licenses" {
  name                = substr(lower("cg-${var.company_name}-licenses-${var.environment}-${var.deployment_suffix}"), 0, 63)
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
    name   = "licenses"
    image  = "${var.acr_url_product}/licenses:${var.imageversion}"
    cpu    = 0.25
    memory = 0.5

    environment_variables = {
      "SQLCMDSERVER"               = var.sql_server_fqdn
      "SQLCMDUSER"                 = var.db_admin_username
      "SQLCMDPASSWORD"             = var.db_admin_password
      "SQLCMDDBNAME"               = var.sm_database_name
      "COMPANY_NAME"               = var.company_name
      "COMPANY_ADMIN_EMAILADDRESS" = "admin@${var.company_name}.com"
      "COMPANY_ID"                 = var.company_id
      "AD_PRODUCT_ID"              = var.ad_product_id
      "DS_PRODUCT_ID"              = var.ds_product_id
      "AI_PRODUCT_ID"              = var.ai_product_id
      "LICENSE_API_URL"            = var.license_api_url
    }

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    smdbmigrate_container_id = substr(var.smdbmigrate_container_id, 0, 8) # Reference the SM DB migration container ID to establish dependency
  })
}