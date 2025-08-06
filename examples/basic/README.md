# Basic XMPro Platform Deployment

This example demonstrates a complete XMPro platform deployment on Azure with all services.

## What This Example Creates

- Complete XMPro Platform (SM, AD, DS, Stream Host)
- Azure SQL Database with automatic migration
- Azure App Services for all components
- Azure Key Vault for secrets management
- Application Insights for monitoring
- Storage Account for file storage

## Usage

```bash
# Set required environment variables (ACR credentials not needed for public registry)
export TF_VAR_db_admin_password="SecurePassword123!"
export TF_VAR_company_admin_password="CompanyAdmin123!"
export TF_VAR_site_admin_password="SiteAdmin123!"

# Deploy
terraform init
terraform apply
```

## Configuration Notes

### Evaluation Mode

This example sets `is_evaluation_mode = true` by default, which:
- Deploys a licenses container with evaluation product IDs and keys
- Forces the company name to "Evaluation" (overrides any `company_name` value)
- Allows quick setup for demos and testing

To use a custom company name for production:
1. Set `is_evaluation_mode = false` in your terraform.tfvars
2. Request licenses from XMPro for your specific company name
3. The evaluation licenses only work with "Evaluation" company name

## Required Variables

- `db_admin_password` - SQL Server admin password
- `company_admin_password` - XMPro company admin password
- `site_admin_password` - XMPro site admin password

## Optional Variables

- `is_evaluation_mode` - Deploy with evaluation licensing (default: true)
- `acr_username` / `acr_password` - Only needed for private container registries

## Accessing Your Deployment

After deployment:
```bash
terraform output ad_app_url    # App Designer
terraform output ds_app_url    # Data Stream Designer
terraform output sm_app_url    # Subscription Manager
```

For complete documentation, see the [main module README](../../README.md).