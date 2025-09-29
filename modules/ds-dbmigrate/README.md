# DS Database Migration Module

This Terraform module creates an Azure Container Group for DS (Data Stream Designer) database migration and initialization.

## Purpose

This module deploys a one-time container that performs database migration and initialization tasks for the DS application. It runs before the DS application starts to ensure the database is properly set up.

## Features

- **One-time execution**: Container uses `restart_policy = "Never"` to run once
- **Database migration**: Connects to DS database using connection string
- **Collection support**: Supports collection-based deployment with optional collection parameters
- **Dependency management**: Creates implicit dependencies with DS database and DS application
- **Container registry support**: Supports both public and private Azure Container Registry

## Usage

```hcl
module "ds_dbmigrate" {
  source = "./modules/ds-dbmigrate"

  company_name        = "xmpro"
  environment         = "dev"
  location            = "East US"
  resource_group_name = "rg-xmpro-dev"
  company_name        = "mycompany"

  # Container configuration
  acr_url_product     = "myregistry.azurecr.io"
  is_private_registry = true
  acr_username        = "registry_user"
  acr_password        = "registry_password"

  # Database configuration
  db_connection_string = "Server=tcp:myserver.database.windows.net;Initial Catalog=DS;..."
  ds_database_id       = "/subscriptions/.../databases/DS"

  # Collection configuration (optional)
  collection_name   = "my-collection"
  collection_id     = "custom-collection-id"
  collection_secret = "custom-collection-secret"

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
| db_connection_string | DS database connection string | `string` | n/a | yes |
| collection_name | Collection name for DS database migration | `string` | `""` | no |
| collection_id | Collection ID for DS database migration | `string` | `""` | no |
| collection_secret | Collection secret for DS database migration | `string` | `""` | no |
| imageversion | Container image version tag (semantic versioning format) | `string` | `"4.5.0-alpha"` | no |
| ds_database_id | DS database ID for dependency tracking | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| container_group_id | Unique identifier of the container group |
| container_group_name | Name of the container group |
| container_ip_address | Public IP address of the container group |
| container_fqdn | Fully qualified domain name of the container group |

## Dependencies

### Implicit Dependencies
- **DS Database**: Container waits for DS database to be created
- **Collection Configuration**: Optional collection parameters (application provides defaults if not specified)

### Creates Dependencies For
- **DS App Service**: DS application waits for this migration to complete

## Environment Variables

The container receives these environment variables:

- `DSDB_CONNECTIONSTRING`: Connection string for the DS database
- `DSDB_COLLECTION_NAME`: Collection name for advanced deployments (optional)
- `DSDB_COLLECTION_ID`: Collection ID for advanced deployments (optional)
- `DSDB_COLLECTION_SECRET`: Collection secret for advanced deployments (optional)

## Application-Level Defaults

The DS database migration application will automatically generate default values for collection parameters when they are not provided or are empty strings. This approach:

- **Simplifies terraform**: No complex logic needed in infrastructure code
- **Application control**: The application handles default generation logic
- **Flexibility**: You can still provide custom values when needed

**Example with application defaults:**
```hcl
module "ds_dbmigrate" {
  collection_name   = ""  # Application will generate default
  collection_id     = ""  # Application will generate default
  collection_secret = ""  # Application will generate default
}
```

## Resource Naming

Resources follow the naming convention:
- Container Group: `cg-{prefix}-dsdbmigrate-{environment}-{location}`

## Tags

Resources are tagged with:
- `product`: "Database Migration Container"
- `createdby`: "jonahfrany"
- `createdfor`: "DS Database migration and initialization"
- `database_id`: First 8 characters of DS database ID (for dependency tracking)

## Notes

- Container has public IP but is only accessible during migration
- Uses 0.2 CPU and 0.5 GB memory for efficient resource usage
- Supports both public and private container registries
- Automatically cleans up after successful migration execution