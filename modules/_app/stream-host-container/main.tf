# Local values for standardized naming
locals {
  # Use custom name if provided, otherwise use standard naming: ci-<company>-sh-<suffix>
  container_name = coalesce(var.custom_container_name, substr(lower("ci-${var.company_name}-sh-${var.name_suffix}"), 0, 63))
}

# Container Group for XMPro Stream Host
resource "azurerm_container_group" "stream_host" {
  name                = local.container_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = var.prod_networking_enabled ? "Private" : "Public"
  os_type             = "Linux"
  restart_policy      = "Always"
  subnet_ids          = var.prod_networking_enabled ? [var.subnet_id] : null

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
    name   = "stream-host"
    image  = "${var.acr_url_product}/stream-host:${var.imageversion}${var.stream_host_variant != "" ? "-${var.stream_host_variant}" : ""}"
    cpu    = var.stream_host_cpu
    memory = var.stream_host_memory

    environment_variables = merge(
      {
        "XM__XMPRO__GATEWAY__SERVERURL"    = var.ds_server_url
        "XM__XMPRO__GATEWAY__COLLECTIONID" = var.stream_host_collection_id
      },
      var.app_insights_connection_string != null ? {
        "XM__XMPRO__GATEWAY__FEATUREFLAGS__ENABLEAPPLICATIONINSIGHTSTELEMETRY" = "true"
      } : {},
      var.environment_variables
    )

    secure_environment_variables = merge(
      {
        "XM__XMPRO__GATEWAY__SECRET" = var.stream_host_collection_secret
      },
      var.app_insights_connection_string != null ? {
        "XM__APPLICATIONINSIGHTS__CONNECTIONSTRING" = var.app_insights_connection_string
      } : {}
    )

    # Dynamic volume configuration - supports both Azure File Share and secret volumes
    dynamic "volume" {
      for_each = var.volumes
      content {
        name       = volume.value.name
        mount_path = volume.value.mount_path
        read_only  = try(volume.value.read_only, false)

        # Azure File Share volume (only set if not using secrets)
        share_name           = volume.value.secret == null ? volume.value.share_name : null
        storage_account_name = volume.value.secret == null ? volume.value.storage_account_name : null
        storage_account_key  = volume.value.secret == null ? sensitive(volume.value.storage_account_key) : null

        # Secret volume (only set if using secrets)
        secret = volume.value.secret != null ? sensitive(volume.value.secret) : null
      }
    }

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  # Log Analytics integration (if provided)
  dynamic "diagnostics" {
    for_each = var.log_analytics_workspace_id != null && var.log_analytics_primary_shared_key != null ? [1] : []
    content {
      log_analytics {
        workspace_id  = var.log_analytics_workspace_id
        workspace_key = var.log_analytics_primary_shared_key
        log_type      = "ContainerInsights"
      }
    }
  }

  tags = merge(var.tags, {
    "Product"    = "XMPro Stream Host Container"
    "CreatedFor" = "Stream processing and agent hosting"
  })
}