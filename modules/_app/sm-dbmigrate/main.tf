# Container Group for SM Database Migration
resource "azurerm_container_group" "smdbmigrate" {
  name                = "ci-${var.company_name}-smdbmigrate-${var.name_suffix}"
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
    name   = "smdbmigrate"
    image  = "${var.acr_url_product}/smdbmigrate:${var.imageversion}"
    cpu    = "0.2"
    memory = "0.5"

    environment_variables = {
      "SMDB_CONNECTIONSTRING"         = var.db_connection_string
      "COMPANY_NAME"                  = var.is_evaluation_mode ? "Evaluation" : var.company_name
      "COMPANY_ADMIN_FIRSTNAME"       = var.company_admin_first_name
      "COMPANY_ADMIN_SURNAME"         = var.company_admin_last_name
      "COMPANY_ADMIN_EMAILADDRESS"    = var.company_admin_email_address != "" ? var.company_admin_email_address : "admin@${var.company_name}.com"
      "COMPANY_ADMIN_USERNAME"        = var.company_admin_username
      "COMPANY_ADMIN_PASSWORD"        = var.company_admin_password
      "SITE_ADMIN_PASSWORD"           = var.site_admin_password
      "AD_BASEURL_CLIENT"             = var.ad_url
      "AI_BASEURL_CLIENT"             = var.ai_url
      "DS_BASEURL_CLIENT"             = var.ds_url
      "XMPRO_NOTEBOOK_BASEURL_CLIENT" = var.nb_url
      "AD_PRODUCT_ID"                 = var.product_ids.ad
      "AI_PRODUCT_ID"                 = var.product_ids.ai
      "DS_PRODUCT_ID"                 = var.product_ids.ds
      "SM_PRODUCT_ID"                 = var.sm_product_id
      "XMPRO_NOTEBOOK_PRODUCT_ID"     = var.product_ids.nb
      "AD_PRODUCT_KEY"                = var.product_keys.ad
      "AI_PRODUCT_KEY"                = var.product_keys.ai
      "DS_PRODUCT_KEY"                = var.product_keys.ds
      "XMPRO_NOTEBOOK_PRODUCT_KEY"    = var.product_keys.nb
      "AI_PRODUCT_ENABLE"             = "true"
      "SM_LOG_LEVEL"                  = "Information"
      "SM_TRUST_ALL_SSL_CERTIFICATES" = "true"
      "SM_LOG_PII"                    = "false"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    database_id = substr(var.sm_database_id, 0, 8) # Reference the database ID to establish dependency
  })
}
