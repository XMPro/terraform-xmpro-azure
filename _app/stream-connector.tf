# Stream Connector - Dedicated Stream Host Container
module "sc_stream_host_container" {
  count  = var.enable_stream_connector_stream_host ? 1 : 0
  source = "../modules/_app/stream-host-container"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = "${var.name_suffix}-sc"

  # Container Registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Container Image
  imageversion        = var.imageversion
  stream_host_variant = var.sc_stream_host_variant

  # Stream Host Configuration (collection credentials required from DS)
  ds_server_url                 = local.ds_base_url
  stream_host_collection_id     = local.sc_collection_id
  stream_host_collection_secret = local.sc_collection_secret
  stream_host_cpu               = var.sc_stream_host_cpu
  stream_host_memory            = var.sc_stream_host_memory

  # Additional environment variables
  environment_variables = var.sc_stream_host_environment_variables

  # Monitoring Integration
  app_insights_connection_string   = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : ""
  log_analytics_workspace_id       = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].workspace_id : ""
  log_analytics_primary_shared_key = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].primary_shared_key : ""

  # Custom resource naming
  custom_container_name = "ci-${var.company_name}-sh-sc-${var.name_suffix}"

  # Networking (same as main stream host - ACI subnet)
  prod_networking_enabled = var.prod_networking_enabled
  subnet_id               = var.prod_networking_enabled ? data.azurerm_subnet.aci[0].id : null

  # Tags
  tags = var.common_tags
}

# Validate that collection credentials are provided when SC stream host is enabled
check "sc_collection_credentials" {
  assert {
    condition     = !var.enable_stream_connector_stream_host || var.sc_stream_host_collection_id != ""
    error_message = "sc_stream_host_collection_id is required when enable_stream_connector_stream_host is true."
  }
  assert {
    condition     = !var.enable_stream_connector_stream_host || var.sc_stream_host_collection_secret != ""
    error_message = "sc_stream_host_collection_secret is required when enable_stream_connector_stream_host is true."
  }
}
