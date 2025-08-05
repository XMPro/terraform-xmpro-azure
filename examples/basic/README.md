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

- `acr_username` / `acr_password` - Container registry credentials
- `db_admin_password` - SQL Server admin password
- `company_admin_password` - XMPro company admin password
- `site_admin_password` - XMPro site admin password

## Optional Variables

- `is_evaluation_mode` - Deploy with evaluation licensing (default: true)
- `acr_username` / `acr_password` - Only needed for private container registries

### SMTP Configuration

Email notifications are disabled by default. To enable email functionality:

1. Set `enable_email_notification = true`
2. Configure the SMTP settings:
   - `smtp_server` - SMTP server address (default: "smtp.example.com")
   - `smtp_port` - SMTP server port (default: 587)
   - `smtp_from_address` - Email from address (default: "notifications@example.com")
   - `smtp_username` - SMTP authentication username (default: "notifications@example.com")
   - `smtp_password` - SMTP authentication password
   - `smtp_enable_ssl` - Enable SSL/TLS (default: true)

Example SMTP configuration in terraform.tfvars:
```hcl
enable_email_notification = true
smtp_server = "smtp.office365.com"
smtp_port = 587
smtp_from_address = "notifications@mycompany.com"
smtp_username = "notifications@mycompany.com"
smtp_password = "your-smtp-password"
smtp_enable_ssl = true
```

## Accessing Your Deployment

After deployment:
```bash
terraform output ad_app_url    # App Designer
terraform output ds_app_url    # Data Stream Designer
terraform output sm_app_url    # Subscription Manager
```

## Advanced Configuration

This basic example now includes the following advanced configuration options:

### Database Configuration
- `db_sku_name` - SQL Database SKU for all databases (default: "Basic")
  - Available SKUs: Basic, S0, S1, S2, S3, P1, P2, P4
- `db_max_size_gb` - Maximum database size in GB (default: 2)
  - Minimum 1 GB for Basic tier, varies by SKU
- `db_collation` - SQL collation for all databases (default: "SQL_Latin1_General_CP1_CI_AS")
  - Use for international deployments requiring different character sets
- `db_zone_redundant` - Enable zone redundancy for high availability (default: false)
  - Provides automated failover across availability zones
- `db_allow_all_ips` - Allow all IP addresses to access databases (default: false)
- `create_local_firewall_rule` - Add your current IP to database firewall (default: false)

### Service Plan SKUs
Customize compute resources for each service:
- `ad_service_plan_sku` - App Designer compute tier (default: "B1")
- `ds_service_plan_sku` - Data Stream Designer compute tier (default: "B1")
- `sm_service_plan_sku` - Subscription Manager compute tier (default: "B1")

Available SKUs: B1, B2, B3, S1, S2, S3, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3

### Stream Host Configuration
Control Stream Host container resources:
- `stream_host_cpu` - CPU allocation (default: 1)
- `stream_host_memory` - Memory in GB (default: 4)
- `stream_host_environment_variables` - Custom environment variables

### DNS Configuration
For custom domain setup:
- `dns_zone_name` - Your DNS zone name (required when `enable_custom_domain = true`)
- `use_existing_dns_zone` - Use existing Azure DNS zone (default: true)

### Container Registry Configuration
- `is_private_registry` - Whether using private container registry (default: false)
  - Set to true if using private ACR with authentication

For complete documentation, see the [main module README](../../README.md).