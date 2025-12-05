# AI Database Migration Module

This Terraform module creates an Azure Container Group for AI (Artificial Intelligence) database migration and initialization.

## Purpose

This module deploys a one-time container that performs database migration and initialization tasks for the AI application. It runs before the AI application starts to ensure the database is properly set up.

## Features

- **One-time execution**: Container uses `restart_policy = "Never"` to run once
- **Database migration**: Connects to AI database using connection string
- **Service integration**: Configured with DS and AD service URLs for AI integration
- **Dependency management**: Creates implicit dependencies with AI database and AI application
- **Container registry support**: Supports both public and private Azure Container Registry

## Usage

```hcl
module "ai_dbmigrate" {
  source = "./modules/ai-dbmigrate"

  company_name        = "xmpro"
  environment         = "dev"
  location            = "East US"
  resource_group_name = "rg-xmpro-dev"
  deployment_suffix   = "abc123"

  # Container configuration
  acr_url_product     = "myregistry.azurecr.io"
  is_private_registry = true
  acr_username        = "registry_user"
  acr_password        = "registry_password"

  # Database configuration
  db_connection_string = "Server=tcp:myserver.database.windows.net;Initial Catalog=AI;..."
  ai_database_id       = "/subscriptions/.../databases/AI"

  # Service URLs for AI integration
  ds_url = "https://ds.mycompany.com"
  ad_url = "https://ad.mycompany.com"

  # Container image version
  imageversion = "4.4.19"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company_name | Company name for resource naming consistency | `string` | n/a | yes |
| deployment_suffix | Random suffix for unique resource names | `string` | n/a | yes |
| environment | Environment identifier (dev, test, staging, prod, qa, demo) | `string` | n/a | yes |
| location | Azure region for resource deployment (valid Azure region) | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| acr_url_product | Azure Container Registry URL | `string` | n/a | yes |
| is_private_registry | Whether to use private registry authentication | `bool` | `false` | no |
| acr_username | Container registry username (required for private registries) | `string` | n/a | yes |
| acr_password | Container registry password (required for private registries) | `string` | n/a | yes |
| db_connection_string | AI database connection string | `string` | n/a | yes |
| ds_url | Data Stream Designer application URL | `string` | n/a | yes |
| ad_url | App Designer application URL | `string` | n/a | yes |
| imageversion | Container image version tag (semantic versioning format) | `string` | `"4.4.19"` | no |
| ai_database_id | AI database ID for dependency tracking | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| container_group_id | Unique identifier of the container group |
| container_group_name | Name of the container group |
| container_ip_address | Public IP address of the container group |
| container_fqdn | Fully qualified domain name of the container group |

## Dependencies

### Implicit Dependencies
- **AI Database**: Container waits for AI database to be created
- **Service URLs**: Requires DS and AD service URLs for AI integration

### Creates Dependencies For
- **AI App Service**: AI application waits for this migration to complete

## Environment Variables

The container receives these environment variables:

- `AIDB_CONNECTIONSTRING`: Connection string for the AI database
- `DS_BASEURL_CLIENT`: Base URL for the Data Stream Designer service
- `AD_BASEURL_CLIENT`: Base URL for the App Designer service

## AI Integration

The AI database migration container is configured with both DS and AD service URLs to enable:

- **Model registration**: Register AI models with DS for stream processing
- **Dashboard integration**: Configure AI insights for AD dashboards
- **Cross-service communication**: Enable AI services to communicate with other XMPro components

## Resource Naming

Resources follow the naming convention:
- Container Group: `cg-{company_name}-aidbmigrate-{environment}-{deployment_suffix}`

## Tags

Resources are tagged with:
- `product`: "Database Migration Container"
- `createdby`: "devops"
- `createdfor`: "AI Database migration and initialization"
- `database_id`: First 8 characters of AI database ID (for dependency tracking)

## Notes

- Container has public IP but is only accessible during migration
- Uses 0.2 CPU and 0.5 GB memory for efficient resource usage
- Supports both public and private container registries
- Automatically cleans up after successful migration execution
- AI-specific migration may include ML model metadata and configuration setup