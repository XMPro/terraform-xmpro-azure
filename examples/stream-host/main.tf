# Stream Host Deployment Example
# This example demonstrates deploying only the XMPro Stream Host container

# Generate a random suffix for resource naming (always needed for unique container names)
resource "random_id" "suffix" {
  byte_length = 4
}

# Create a resource group for the stream host (only if not using existing)
module "resource_group" {
  count = var.use_existing_resource_group ? 0 : 1

  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure/modules/resource-group"

  # For local development:
  # source = "../../modules/resource-group"

  # For specific latest stable released version:
  # source = "github.com/XMPro/terraform-xmpro-azure/modules/resource-group?ref=v4.5.2"

  name     = "rg-${var.company_name}-${var.environment}-sh-${random_id.suffix.hex}"
  location = var.location

  tags = merge(var.tags, {
    "Environment" = var.environment
    "Company"     = var.company_name
  })
}

# Data source to get existing resource group (only if using existing)
data "azurerm_resource_group" "existing" {
  count = var.use_existing_resource_group ? 1 : 0
  name  = var.existing_resource_group_name
}

# Deploy the Stream Host container
module "stream_host" {
  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure/modules/stream-host-container"

  # For local development:
  # source = "../../modules/stream-host-container"

  # For specific latest stable released version:
  # source = "github.com/XMPro/terraform-xmpro-azure/modules/stream-host-container?ref=v4.5.2"

  # Core settings
  environment         = var.environment
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  company_name        = var.company_name
  name_suffix         = random_id.suffix.hex

  # Container registry settings
  is_private_registry = var.is_private_registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  imageversion        = var.imageversion
  stream_host_variant = var.stream_host_variant

  # Stream Host specific configuration
  ds_server_url                 = var.ds_server_url
  stream_host_collection_id     = var.stream_host_collection_id
  stream_host_collection_secret = var.stream_host_collection_secret

  # Resource allocation
  stream_host_cpu    = var.stream_host_cpu
  stream_host_memory = var.stream_host_memory

  # Optional monitoring (from monitoring module or external)
  app_insights_connection_string   = var.enable_monitoring ? module.monitoring[0].app_insights_connection_string : var.existing_app_insights_connection_string
  log_analytics_workspace_id       = var.enable_monitoring ? module.monitoring[0].log_analytics_workspace_id : var.existing_log_analytics_workspace_id
  log_analytics_primary_shared_key = var.enable_monitoring ? module.monitoring[0].log_analytics_primary_shared_key : var.existing_log_analytics_primary_shared_key

  # Additional environment variables (if needed)
  environment_variables = var.environment_variables

  # Volume mounts (if needed)
  volumes = var.volumes

  # Resource tagging
  tags = merge(var.tags, {
    "Environment" = var.environment
    "Company"     = var.company_name
  })
}

# Monitoring Module (independent of alerting)
module "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure/modules/monitoring"

  # For local development:
  # source = "../../modules/monitoring"

  company_name        = var.company_name
  environment         = var.environment
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  # Optional parameters
  enable_log_analytics = true
  enable_app_insights  = true
  app_insights_name    = "appinsights-${var.company_name}-${var.environment}-sh"
  log_analytics_daily_quota_gb = var.log_analytics_quota

  tags = merge(var.tags, {
    "Environment" = var.environment
    "Company"     = var.company_name
  })
}

# Alerting for Stream Host Container
module "stream_host_alerting" {
  count = var.enable_alerting ? 1 : 0

  # Use the latest version from GitHub  
  source = "github.com/XMPro/terraform-xmpro-azure/modules/alerting"

  # For local development:
  # source = "../../modules/alerting"

  company_name        = var.company_name
  environment         = var.environment
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  app_insights_id     = var.enable_monitoring ? module.monitoring[0].app_insights_id : var.external_app_insights_id

  # Alerting configuration
  enable_email_alerts      = var.enable_email_alerts
  alert_email_addresses    = var.alert_email_addresses
  enable_sms_alerts        = var.enable_sms_alerts
  alert_phone_numbers      = var.alert_phone_numbers
  alert_phone_country_code = var.alert_phone_country_code
  enable_webhook_alerts    = var.enable_webhook_alerts
  alert_webhook_urls       = var.alert_webhook_urls

  # Container metrics configuration - reference the stream host container
  container_group_id          = module.stream_host.container_group_id
  enable_cpu_alerts           = var.enable_cpu_alerts
  cpu_alert_threshold         = var.cpu_alert_threshold
  cpu_alert_severity          = var.cpu_alert_severity
  stream_host_cpu_cores       = var.stream_host_cpu
  enable_memory_alerts        = var.enable_memory_alerts
  memory_alert_threshold      = var.memory_alert_threshold
  memory_alert_severity       = var.memory_alert_severity
  stream_host_memory_gb       = var.stream_host_memory
  enable_container_restart_alerts = var.enable_container_restart_alerts
  enable_container_stop_alerts    = var.enable_container_stop_alerts

  alert_window_size          = var.alert_window_size
  alert_evaluation_frequency = var.alert_evaluation_frequency

  tags = merge(var.tags, {
    "Environment" = var.environment
    "Company"     = var.company_name
  })
}