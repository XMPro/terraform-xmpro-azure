# Existing Database XMPro Platform Deployment

This example demonstrates deploying XMPro platform using existing SQL Server and databases.

## What This Example Does

- Deploys XMPro platform components to existing databases
- Skips SQL Server and database creation
- Skips database migration containers
- Uses provided database connection details

## Configuration

This example sets:
- `use_existing_database = true`
- `existing_sql_server_fqdn` - Fully qualified domain name of your existing SQL Server

## Usage

```bash
# Configure existing database details
export TF_VAR_existing_sql_server_fqdn="my-existing-server.database.windows.net"

# Set other required variables (ACR credentials not needed for public registry)
# export TF_VAR_acr_username="your-username"  # Only for private registries
# export TF_VAR_acr_password="your-password"  # Only for private registries

terraform init
terraform apply
```

## Prerequisites

- Existing SQL Server with databases for AD, DS, and SM
- Proper connectivity and firewall rules configured
- Database schemas can be empty (apps will initialize)

For complete documentation, see the [main module README](../../README.md).