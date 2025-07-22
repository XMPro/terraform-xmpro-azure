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
- `existing_sql_server_name` - Your existing SQL Server
- `existing_sql_server_resource_group` - Resource group containing the server
- `existing_database_names` - Map of existing database names

## Usage

```bash
# Configure existing database details
export TF_VAR_existing_sql_server_name="my-existing-server"
export TF_VAR_existing_sql_server_resource_group="my-rg"

# Set other required variables
export TF_VAR_acr_username="your-username"
export TF_VAR_acr_password="your-password"

terraform init
terraform apply
```

## Prerequisites

- Existing SQL Server with databases for AD, DS, and SM
- Proper connectivity and firewall rules configured
- Database schemas can be empty (apps will initialize)

For complete documentation, see the [main module README](../../README.md).