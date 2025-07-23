# Basic XMPro Platform Deployment Example

This example demonstrates a complete XMPro platform deployment on Azure using the default configuration. It creates all necessary infrastructure components including SQL Server, databases, App Services, and supporting Azure services.

## What This Example Does

- Deploys a complete XMPro platform with all core services (SM, AD, DS)
- Creates new SQL Server and databases for the platform
- Sets up Azure App Services for hosting containerized applications
- Configures Azure Key Vault for secure credential storage
- Includes database migration containers for schema initialization
- Deploys licenses container for evaluation mode (default)

## Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.0
- Appropriate Azure subscription permissions to create resources
- Access to XMPro container images (ACR credentials)

## Required Environment Variables

Set these environment variables before running Terraform:

```bash
# Azure authentication (if not using Azure CLI)
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"

# Container registry credentials (not needed for public XMPro registry)
# export TF_VAR_acr_username="your-acr-username"  # Only for private registries
# export TF_VAR_acr_password="your-acr-password"  # Only for private registries
```

## Basic Usage

1. **Clone and navigate to the example:**
   ```bash
   git clone <repository-url>
   cd examples/basic
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and customize variables:**
   ```bash
   # Edit terraform.tfvars or set variables via command line
   terraform plan -var="environment=myenv" -var="company_name=mycompany"
   ```

4. **Deploy the platform:**
   ```bash
   terraform apply
   ```

5. **Access your deployment:**
   After successful deployment, Terraform will output the URLs for accessing the XMPro services.

## Key Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name for resource identification | `"sandbox"` |
| `location` | Azure region for deployment | `"southeastasia"` |
| `company_name` | Company name used in resource naming | `"xmprosbx"` |
| `imageversion` | Docker image version to deploy | `"4.5.0"` |
| `enable_custom_domain` | Enable custom domain configuration | `false` |

## Important Notes

- **Default Passwords**: This example uses default passwords for demonstration. **Change these for production use**.
- **ACR Access**: Ensure you have access to the specified Azure Container Registry
- **Resource Costs**: This deployment creates multiple Azure resources that incur costs
- **Clean Up**: Run `terraform destroy` to remove all created resources

## Differences From Other Examples

- **vs. existing-database**: Creates new SQL Server and databases instead of using existing ones
- **vs. sm-only**: Deploys the complete platform (SM, AD, DS) instead of just SM

## Next Steps

After deployment:
1. Access the SM (Subscription Manager) portal using the output URL
2. Log in with the configured admin credentials
3. Configure your industrial data sources in DS (Data Stream Designer)
4. Build dashboards in AD (App Designer)

## Documentation Links

- [Main Module Documentation](../../README.md)
- [XMPro Platform Documentation](https://documentation.xmpro.com)
- [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues specific to this example, please check:
- Terraform plan output for resource conflicts
- Azure resource quotas and limits
- Container registry access and image availability