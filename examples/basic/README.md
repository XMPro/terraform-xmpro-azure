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
# Set required environment variables
export TF_VAR_acr_username="your-username"
export TF_VAR_acr_password="your-password"
export TF_VAR_db_admin_password="SecurePassword123!"
export TF_VAR_company_admin_password="CompanyAdmin123!"
export TF_VAR_site_admin_password="SiteAdmin123!"

# Deploy
terraform init
terraform apply
```

## Required Variables

- `acr_username` / `acr_password` - Container registry credentials
- `db_admin_password` - SQL Server admin password
- `company_admin_password` - XMPro company admin password
- `site_admin_password` - XMPro site admin password

## Accessing Your Deployment

After deployment:
```bash
terraform output ad_url    # App Designer
terraform output ds_url    # Data Stream Designer
terraform output sm_url    # Subscription Manager
```

For complete documentation, see the [main module README](../../README.md).