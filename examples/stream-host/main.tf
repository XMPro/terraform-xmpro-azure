# Stream Host Deployment Example
# This example demonstrates deploying only the XMPro Stream Host container

# Create a resource group for the stream host
module "resource_group" {
  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure//modules/resource-group"
  
  # For local development:
  # source = "../../modules/resource-group"
  
  # For a specific version:
  # source = "github.com/XMPro/terraform-xmpro-azure//modules/resource-group?ref=v4.5.0"

  environment    = var.environment
  location       = var.location
  company_name   = var.company_name
}

# Deploy the Stream Host container
module "stream_host" {
  # Use the latest version from GitHub
  source = "github.com/XMPro/terraform-xmpro-azure//modules/stream-host-container"
  
  # For local development:
  # source = "../../modules/stream-host-container"
  
  # For a specific version:
  # source = "github.com/XMPro/terraform-xmpro-azure//modules/stream-host-container?ref=v4.5.0"

  # Core settings
  environment         = var.environment
  location           = var.location
  resource_group_name = module.resource_group.name
  company_name       = var.company_name

  # Container registry settings
  is_private_registry = var.is_private_registry
  acr_url_product    = var.acr_url_product
  acr_username       = var.acr_username
  acr_password       = var.acr_password
  imageversion       = var.imageversion

  # Stream Host specific configuration
  ds_server_url                    = var.ds_server_url
  stream_host_collection_id        = var.stream_host_collection_id
  stream_host_collection_secret    = var.stream_host_collection_secret

  # Resource allocation
  stream_host_cpu    = var.stream_host_cpu
  stream_host_memory = var.stream_host_memory

  # Optional monitoring (if provided)
  app_insights_connection_string     = var.app_insights_connection_string
  log_analytics_workspace_id         = var.log_analytics_workspace_id
  log_analytics_primary_shared_key   = var.log_analytics_primary_shared_key

  # Additional environment variables (if needed)
  environment_variables = var.environment_variables

  # Volume mounts (if needed)
  volumes = var.volumes
}