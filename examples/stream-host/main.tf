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
  # source = "github.com/XMPro/terraform-xmpro-azure//modules/resource-group"

  # For local development:
  # source = "../../modules/resource-group"

  # For specific latest stable released version:
  source = "github.com/XMPro/terraform-xmpro-azure//modules/resource-group?ref=v4.5.3"

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
  # source = "github.com/XMPro/terraform-xmpro-azure//modules/stream-host-container"

  # For local development:
  # source = "../../modules/stream-host-container"

  # For specific latest stable released version:
  source = "github.com/XMPro/terraform-xmpro-azure//modules/stream-host-container?ref=v4.5.3"

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

  # Optional monitoring (if provided)
  app_insights_connection_string   = var.app_insights_connection_string
  log_analytics_workspace_id       = var.log_analytics_workspace_id
  log_analytics_primary_shared_key = var.log_analytics_primary_shared_key

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