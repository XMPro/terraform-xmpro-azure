# Existing Database XMPro Platform Deployment

This example demonstrates deploying XMPro platform using existing SQL Server and databases.

## What This Example Does

- Deploys XMPro platform components to existing databases
- Skips SQL Server and database creation
- Skips database migration containers
- Skips licenses container deployment (when using existing databases)
- Uses provided database connection details

## Configuration

This example sets:
- `existing_sql_server_fqdn` - Fully qualified domain name of your existing SQL Server
- `is_evaluation_mode = true` - Default evaluation mode setting

### Evaluation Mode with Existing Database

When using existing databases:
- The licenses container is automatically skipped regardless of `is_evaluation_mode` setting
- You'll need to manage licenses manually through the SM interface
- The `is_evaluation_mode` variable still defaults to `true` for consistency but doesn't deploy the licenses container

To use a custom company name:
1. Set `is_evaluation_mode = false` in your terraform.tfvars
2. Request licenses from XMPro for your specific company name
3. Upload licenses manually after deployment

## Usage

```bash
# Configure existing database details
export TF_VAR_existing_sql_server_name="my-existing-server"
export TF_VAR_existing_sql_server_resource_group="my-rg"

# Set required passwords
export TF_VAR_db_admin_password="YourExistingPassword123!"
export TF_VAR_company_admin_password="CompanyAdmin123!"
export TF_VAR_site_admin_password="SiteAdmin123!"

# Set other variables (ACR credentials not needed for public registry)
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