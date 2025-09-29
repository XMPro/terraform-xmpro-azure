# Stream Host Container Module

This module creates an Azure Container Instance for hosting XMPro Stream Host containers. The Stream Host provides real-time data processing capabilities and hosts custom agents for data collection and transformation.

**Note: This module is always deployed as part of every XMPro installation to provide the default collection for stream processing.**

## Features

- **Container Instance**: Deploys Stream Host as Azure Container Instance with public IP
- **Monitoring Integration**: Integrates with Application Insights and Log Analytics
- **Dynamic Configuration**: Supports custom environment variables and volume mounts
- **Security**: Supports both public and private container registries
- **Scalability**: Configurable CPU and memory allocation

## Usage

```hcl
module "stream_host_container" {
  source = "./modules/stream-host-container"

  # Required variables
  company_name        = "xmpro"
  environment         = "dev"
  location            = "australiaeast"
  resource_group_name = "rg-xmpro-dev-australiaeast"
  company_name        = "dev"

  # Container Registry
  acr_url_product     = "xmpro.azurecr.io"
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = true

  # Container Image
  imageversion = "4.5.0-alpha"

  # Stream Host Configuration
  ds_server_url                   = "https://ds.dev.xmpro.com"
  stream_host_collection_id       = "your-collection-id"
  stream_host_collection_secret   = "your-collection-secret"

  # Resource allocation
  stream_host_cpu    = 1
  stream_host_memory = 4

  # Monitoring Integration
  app_insights_connection_string     = "InstrumentationKey=abc123..."
  log_analytics_workspace_id         = "/subscriptions/.../workspaces/..."
  log_analytics_primary_shared_key   = "base64-encoded-key"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company_name | The company name used for all resources in this module | `string` | n/a | yes |
| environment | The environment name for resource identification | `string` | n/a | yes |
| location | The Azure location where all resources should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the resources | `string` | n/a | yes |
| acr_url_product | The URL of the Azure Container Registry for product images | `string` | n/a | yes |
| acr_username | The username for the Azure Container Registry | `string` | n/a | yes |
| acr_password | The password for the Azure Container Registry | `string` | n/a | yes |
| imageversion | The version of the container image to use | `string` | `"4.5.3"` | no |
| stream_host_variant | The Stream Host Docker image variant suffix. Options: '' (default, same as bookworm-slim), 'bookworm-slim', 'bookworm-slim-python3.12', 'alpine3.21' | `string` | `""` | no |
| ds_server_url | The URL of the Data Stream server | `string` | n/a | yes |
| stream_host_collection_id | The collection ID for DS authentication | `string` | n/a | yes |
| stream_host_collection_secret | The collection secret for DS authentication | `string` | n/a | yes |
| is_private_registry | Whether to use private registry authentication | `bool` | `false` | no |
| stream_host_cpu | CPU allocation for the container | `number` | `1` | no |
| stream_host_memory | Memory allocation (in GB) for the container | `number` | `4` | no |
| environment_variables | Additional environment variables | `map(string)` | `{}` | no |
| volumes | List of volumes to be mounted | `list(object)` | `[]` | no |
| app_insights_connection_string | Application Insights connection string | `string` | `null` | no |
| log_analytics_workspace_id | Log Analytics workspace ID | `string` | `null` | no |
| log_analytics_primary_shared_key | Log Analytics workspace key | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| container_group_id | The ID of the stream host container group |
| container_group_name | The name of the stream host container group |
| container_group_fqdn | The FQDN of the stream host container group |
| stream_host_id | The unique ID generated for the stream host instance |
| ip_address | The public IP address of the stream host container group |

## Integration with XMPro Platform

This module is designed to integrate seamlessly with the XMPro v5 platform and is **automatically deployed** with every XMPro installation:

1. **Default Collection**: Provides the default stream host collection for immediate use
2. **Data Stream Integration**: Connects to the DS server URL for real-time data processing
3. **Monitoring**: Uses the same Application Insights and Log Analytics as other platform components
4. **Container Registry**: Uses the same ACR as other XMPro containers
5. **Resource Naming**: Follows the same naming conventions as other platform resources

### Automatic Deployment

The Stream Host container is automatically created during XMPro platform deployment and does not require manual enabling. This ensures that users have immediate access to stream processing capabilities upon installation.

## Examples

### Basic Configuration

```hcl
module "stream_host_container" {
  source = "./modules/stream-host-container"

  company_name        = "xmpro"
  environment         = "dev"
  location            = "australiaeast"
  resource_group_name = "rg-xmpro-dev-australiaeast"
  company_name        = "dev"

  acr_url_product               = "xmpro.azurecr.io"
  acr_username                  = var.acr_username
  acr_password                  = var.acr_password
  is_private_registry           = true
  imageversion                  = "4.5.0-alpha"

  ds_server_url                 = "https://ds.dev.xmpro.com"
  stream_host_collection_id     = var.stream_host_collection_id
  stream_host_collection_secret = var.stream_host_collection_secret
}
```

### Advanced Configuration with Custom Variables

```hcl
module "stream_host_container" {
  source = "./modules/stream-host-container"

  company_name        = "xmpro"
  environment         = "dev"
  location            = "australiaeast"
  resource_group_name = "rg-xmpro-dev-australiaeast"
  company_name        = "dev"

  acr_url_product               = "xmpro.azurecr.io"
  acr_username                  = var.acr_username
  acr_password                  = var.acr_password
  is_private_registry           = true
  imageversion                  = "4.5.3"

  ds_server_url                 = "https://ds.dev.xmpro.com"
  stream_host_collection_id     = var.stream_host_collection_id
  stream_host_collection_secret = var.stream_host_collection_secret

  # Resource allocation
  stream_host_cpu    = 2
  stream_host_memory = 8

  # Use Python variant for pip package installation
  stream_host_variant = "bookworm-slim-python3.12"

  # Custom environment variables for Python packages
  # Note: These pip and custom env vars are only available with bookworm-slim-python3.12 variant
  environment_variables = {
    "ADDITIONAL_INSTALLS" = "build-base gcc g++ python3-dev"
    "SH_PIP_MODULES"     = "pandas numpy scikit-learn"
    "PIP_REQUIREMENTS_PATH" = "/app/requirements"
  }

  # Monitoring integration
  app_insights_connection_string     = module.monitoring.app_insights_connection_string
  log_analytics_workspace_id         = module.monitoring.log_analytics_workspace_id
  log_analytics_primary_shared_key   = module.monitoring.log_analytics_primary_shared_key
}
```

## Notes

- The container is deployed with a public IP address and DNS name for external access
- The module generates a unique UUID for each Stream Host instance
- Environment variables are automatically configured for XMPro platform integration
- The container uses restart policy "Always" to ensure high availability
- Resource allocation can be adjusted based on workload requirements

## Stream Host Variants

The Stream Host supports multiple Docker image variants configured via the `stream_host_variant` variable. For detailed information about available variants and their capabilities, see the [Stream Host Docker Variants documentation](https://documentation.xmpro.com/4.5/src/installation/install-stream-host/docker.html#available-variants).

**Important**: Python package installation environment variables (`SH_PIP_MODULES`, `PIP_REQUIREMENTS_PATH`, `ADDITIONAL_INSTALLS`) are only available with the `bookworm-slim-python3.12` variant.