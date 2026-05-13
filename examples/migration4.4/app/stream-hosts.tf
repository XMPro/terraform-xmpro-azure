# Additional Stream Host Deployments
# Deploy multiple Stream Host containers, each with unique collection credentials
# Each stream host is configured via the stream_hosts map variable

# Deploy additional Stream Host containers
module "stream_host" {
  for_each = var.stream_hosts
  source   = "../../../modules/_app/stream-host-container"

  # Core settings
  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = each.key # Use map key as name suffix (e.g., "sh01", "sh02")

  # Container registry settings
  is_private_registry = var.acr_username != ""
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  imageversion        = each.value.imageversion != "" ? each.value.imageversion : var.imageversion
  stream_host_variant = each.value.variant

  # Stream Host specific configuration
  # DS URL: Auto-populated from main deployment (shared across all stream hosts)
  # Collection credentials: Unique per stream host (provided by user from DS)
  ds_server_url                 = var.stream_host_ds_server_url != "" ? var.stream_host_ds_server_url : module.applications.ds_app_url
  stream_host_collection_id     = each.value.collection_id
  stream_host_collection_secret = each.value.collection_secret

  # Resource allocation (per stream host)
  stream_host_cpu    = each.value.cpu
  stream_host_memory = each.value.memory

  # Monitoring (from infrastructure layer)
  app_insights_connection_string   = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : null
  log_analytics_workspace_id       = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].workspace_id : null
  log_analytics_primary_shared_key = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].primary_shared_key : null

  # Additional configuration (per stream host)
  environment_variables = each.value.environment_variables
  volumes               = each.value.volumes

  # Tags
  tags = {
    "Billing"   = var.billing_tag
    "Keep"      = var.keep_or_delete_tag
    "Company"   = var.company_name
    "Layer"     = "Application"
    "Component" = "StreamHost"
    "Name"      = each.key # Tag with the name suffix for identification
  }
}

# Optional: Alerting for additional Stream Hosts
module "stream_host_alerting" {
  for_each = var.stream_host_enable_alerting ? var.stream_hosts : {}
  source   = "../../../modules/_infra/alerting"

  company_name        = var.company_name
  name_suffix         = each.key
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.this.location
  app_insights_id     = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].id : null

  # Alerting configuration
  enable_email_alerts      = length(var.stream_host_alert_email_addresses) > 0
  alert_email_addresses    = var.stream_host_alert_email_addresses
  enable_sms_alerts        = false
  alert_phone_numbers      = []
  alert_phone_country_code = "1"
  enable_webhook_alerts    = length(var.stream_host_alert_webhook_urls) > 0
  alert_webhook_urls       = var.stream_host_alert_webhook_urls

  # Container metrics configuration (per stream host)
  container_group_id              = module.stream_host[each.key].container_group_id
  enable_cpu_alerts               = var.stream_host_enable_cpu_alerts
  cpu_alert_threshold             = var.stream_host_cpu_alert_threshold
  cpu_alert_severity              = 2
  stream_host_cpu_cores           = each.value.cpu
  enable_memory_alerts            = var.stream_host_enable_memory_alerts
  memory_alert_threshold          = var.stream_host_memory_alert_threshold
  memory_alert_severity           = 2
  stream_host_memory_gb           = each.value.memory
  enable_container_restart_alerts = var.stream_host_enable_restart_alerts
  enable_container_stop_alerts    = var.stream_host_enable_stop_alerts

  alert_window_size          = "PT5M"
  alert_evaluation_frequency = "PT1M"

  tags = {
    "Billing"   = var.billing_tag
    "Keep"      = var.keep_or_delete_tag
    "Company"   = var.company_name
    "Layer"     = "Application"
    "Component" = "StreamHost-Alerting"
    "Name"      = each.key
  }
}
