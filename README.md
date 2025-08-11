# XMPro Azure Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A comprehensive Terraform module for deploying the XMPro Industrial IoT platform on Microsoft Azure. This module creates a complete XMPro environment ready for production workloads with all necessary Azure services, database infrastructure, monitoring, and security components.

## 🏗️ Architecture Overview

The XMPro platform consists of multiple interconnected services that provide a complete Industrial IoT solution:

### Core Services
- **SM (Subscription Manager)**: Identity and subscription management service
- **AD (App Designer)**: Visual application builder for IoT dashboards  
- **DS (Data Stream Designer)**: Real-time data processing and analytics engine
- **AI (AI Designer)**: AI/ML integration and model management (optional)
- **Stream Host**: Container-based stream processing runtime

### Supporting Infrastructure
- **Azure SQL Database**: Separate databases for each service (SM, AD, DS, AI)
- **Azure App Services**: Containerized hosting for web applications
- **Azure Container Instances**: Database migration and initialization containers
- **Azure Key Vault**: Secure storage for certificates and secrets
- **Azure Storage Account**: File storage for deployment artifacts
- **Azure DNS Zone**: Custom domain management (optional)
- **Application Insights**: Monitoring and telemetry
- **Log Analytics**: Centralized logging

For a visual representation of the architecture, see the [Azure Architecture Diagram](https://documentation.xmpro.com/4.5/installation/deployment/azure-terraform/#architecture).

> ⚠️ **Security Notice**  
> Use Azure Key Vault, environment variables, or your CI pipeline's secret store for all passwords, access tokens, and connection strings.  
> The credentials shown below are sample values only – never commit real secrets to version control.

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- Azure subscription with appropriate permissions
- Docker registry access (Azure Container Registry recommended)

### Module Source Options

This module is available directly from GitHub and can be referenced in your Terraform configuration:

**Recommended: Use a specific version for production workloads**
```hcl
module "xmpro_platform" {
  source = "github.com/XMPro/terraform-xmpro-azure?ref=v5.0.0"
  # ... configuration
}
```

**Use the latest version (main branch)**
```hcl
module "xmpro_platform" {
  source = "github.com/XMPro/terraform-xmpro-azure"
  # ... configuration
}
```

**Use SSH for private repositories or when you have SSH keys configured**
```hcl
module "xmpro_platform" {
  source = "git@github.com:XMPro/terraform-xmpro-azure.git?ref=v5.0.0"
  # ... configuration
}
```

### Basic Usage

```hcl
module "xmpro_platform" {
  source = "github.com/XMPro/terraform-xmpro-azure?ref=v5.0.0"

  # Basic Configuration
  company_name = "mycompany"  # Note: Requires licenses from XMPro
  environment  = "dev"
  location     = "australiaeast"

  # Database Configuration
  db_admin_username = "sqladmin"
  db_admin_password = "YourSecurePassword123!"

  # Application Configuration
  company_admin_password = "AdminPassword123!"
  site_admin_password    = "SitePassword123!"

  # Container Registry (public XMPro registry - no credentials needed)
  acr_url_product = "xmpro.azurecr.io"
  imageversion    = "5.0.0"

  # Optional: Custom Domain
  enable_custom_domain = false  # Conservative default
  # dns_zone_name       = "mycompany.xmpro.com"  # Set if enable_custom_domain = true
}
```

### Using Custom Company Name (For Production Workloads)

```hcl
module "xmpro_platform" {
  source = "github.com/XMPro/terraform-xmpro-azure?ref=v5.0.0"

  # Basic Configuration
  company_name = "mycompany"    # Custom company name requires licenses
  environment  = "prod"
  location     = "eastus"
  
  # IMPORTANT: Disable evaluation mode to use custom company name
  is_evaluation_mode = false     # Required for custom company names

  # Container Registry Configuration
  acr_url_product = "xmpro.azurecr.io"
  imageversion    = "5.0.0"

  # Secure Credentials
  db_admin_password      = var.db_admin_password
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
}
```

> **Note**: Remember to request licenses from XMPro for your custom company name before deployment.

### Advanced Configuration with Existing Database

```hcl
module "xmpro_platform" {
  source = "github.com/XMPro/terraform-xmpro-azure?ref=v5.0.0"

  # Basic Configuration
  company_name = "enterprise"    # Requires is_evaluation_mode = false
  environment  = "prod"
  location     = "eastus"

  # Existing Database Configuration
  use_existing_database    = true
  existing_sql_server_fqdn = "existing-server.database.windows.net"
  db_admin_username        = "admin"
  db_admin_password        = "ExistingPassword123!"

  # For Production Workloads (no built-in licensing)
  is_evaluation_mode = false

  # Service Scaling
  sm_service_plan_sku = "P1v3"
  ad_service_plan_sku = "P1v3"
  ds_service_plan_sku = "P1v3"
  ai_service_plan_sku = "P1v3"

  # Stream Host Resources
  stream_host_cpu    = 2
  stream_host_memory = 8

  # Email Configuration
  enable_email_notification = true
  smtp_server               = "smtp.company.com"
  smtp_from_address         = "noreply@company.com"
  smtp_username             = "smtp-user"
  smtp_password             = "smtp-password"
  smtp_port                 = 587
  smtp_enable_ssl           = true

  tags = {
    Environment = "Production"
    Team        = "Platform"
    CostCenter  = "IT"
  }
}
```

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## 🔧 Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |
| random | ~> 3.1 |
| external | ~> 2.2 |

## 📥 Inputs

### Required Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| company_name | Company name for resource naming (max 18 chars) | `string` | `"evaluation"` |
| db_admin_password | Database admin password | `string` | `"P@ssw0rd1234!"` |
| company_admin_password | Company admin password | `string` | `"P@ssw0rd1234!"` |
| site_admin_password | Site admin password | `string` | `"P@ssw0rd1234!"` |

> **Note**: While these variables have defaults for development convenience, you should override them with secure passwords for production workloads.
> 
> **Important**: When `is_evaluation_mode = true`, the `company_name` is automatically set to "Evaluation" regardless of the value you provide. When using `is_evaluation_mode = false` (default) with a custom `company_name`, licenses must be requested from XMPro. The evaluation licenses are only valid for the "Evaluation" company name.

### Basic Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| environment | Environment name (e.g., dev, test, prod) | `string` | `"dev"` |
| location | Azure region for resources | `string` | `"australiaeast"` |
| company_id | Company ID for resource identification | `number` | `2` |

### Database Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| db_admin_username | Database admin username | `string` | `"sqladmin"` |
| use_existing_database | Use existing SQL Server and databases | `bool` | `false` |
| existing_sql_server_fqdn | Existing SQL Server FQDN | `string` | `""` |
| db_allow_all_ips | Allow all IPs to connect to database | `bool` | `false` |

### Container Registry

| Name | Description | Type | Default |
|------|-------------|------|---------|
| acr_url_product | Azure Container Registry URL | `string` | `"xmpro.azurecr.io"` |
| acr_username | ACR username (for private registries) | `string` | `""` |
| acr_password | ACR password (for private registries) | `string` | `""` |
| is_private_registry | Use private registry authentication | `bool` | `false` |
| imageversion | Docker image version | `string` | `"4.5.0.82-alpha-9db64dab7e"` |

### DNS and Domain Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_custom_domain | Enable custom domain for web apps | `bool` | `false` |
| dns_zone_name | DNS zone name | `string` | `"jfmhnda.nonprod.xmprodev.com"` |
| use_existing_dns_zone | Use existing DNS zone | `bool` | `false` |

### Service Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_ai | Enable AI service and database | `bool` | `false` |
| sm_service_plan_sku | SM App Service plan SKU | `string` | `"B1"` |
| ad_service_plan_sku | AD App Service plan SKU | `string` | `"B1"` |
| ds_service_plan_sku | DS App Service plan SKU | `string` | `"B1"` |
| ai_service_plan_sku | AI App Service plan SKU | `string` | `"B1"` |

### Evaluation Mode

| Name | Description | Type | Default |
|------|-------------|------|---------|
| is_evaluation_mode | Deploy with built-in license provisioning | `bool` | `false` |

### Company Admin Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| company_admin_first_name | Company admin first name | `string` | `"admin"` |
| company_admin_last_name | Company admin last name | `string` | `"user"` |
| company_admin_email_address | Company admin email | `string` | `""` |
| company_admin_username | Company admin username | `string` | `""` |

### Email Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enable_email_notification | Enable email notifications | `bool` | `false` |
| smtp_server | SMTP server address | `string` | `"sinprd0310.outlook.com"` |
| smtp_from_address | SMTP from address | `string` | `"Qa.Test@xmpro.com"` |
| smtp_username | SMTP username | `string` | `"Qa.Test@xmpro.com"` |
| smtp_password | SMTP password | `string` | `"stored-in-keeper"` |
| smtp_port | SMTP port | `number` | `587` |
| smtp_enable_ssl | Enable SSL for SMTP | `bool` | `false` |

### Stream Host Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| stream_host_cpu | CPU allocation for stream host | `number` | `1` |
| stream_host_memory | Memory allocation (GB) for stream host | `number` | `4` |
| stream_host_environment_variables | Additional environment variables | `map(string)` | `{}` |
| stream_host_variant | Stream Host Docker image variant. Options: '' (default), 'bookworm-slim', 'bookworm-slim-python3.12', 'alpine3.21' | `string` | `""` |

### Deployment Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| is_azdo_pipeline | Running in Azure DevOps pipeline | `bool` | `false` |

### Tagging

| Name | Description | Type | Default |
|------|-------------|------|---------|
| tags | Map of tags to apply to all resources | `map(string)` | See defaults |

## 📤 Outputs

### Resource Information

| Name | Description |
|------|-------------|
| resource_group_name | The name of the resource group |
| environment | The environment name |
| location | The Azure location |

### Database Information

| Name | Description |
|------|-------------|
| sql_server_name | The name of the SQL server |
| sql_server_fqdn | The fully qualified domain name of the SQL server |

### DNS Information

| Name | Description |
|------|-------------|
| dns_zone_nameservers | The nameservers of the DNS zone |
| dns_zone_name | The name of the DNS zone |
| platform_domain | The platform domain being used |

### Application URLs

| Name | Description |
|------|-------------|
| ad_app_url | The URL of the AD app service |
| ds_app_url | The URL of the DS app service |
| sm_app_url | The URL of the SM app service |
| ai_app_url | The URL of the AI app service |

### Infrastructure Information

| Name | Description |
|------|-------------|
| stream_host_container_id | The ID of the stream host container group |
| company_details | Details about the company admin |

### Deployment Warnings

| Name | Description |
|------|-------------|
| existing_database_firewall_warning | Warning about firewall rules when using existing database |
| existing_database_migration_warning | Warning about migration compatibility |
| evaluation_mode_status | Status of evaluation mode deployment |

## 🧩 Submodules

This module is composed of the following submodules:

### Core Application Services
- **ad-app-service-container**: App Designer web application hosting
- **ds-app-service-container**: Data Stream Designer web application hosting  
- **sm-app-service**: Subscription Manager web application hosting
- **ai-app-service-container**: AI Designer web application hosting (optional)

### Database Services
- **database**: Azure SQL Server and databases for all services
- **ad-dbmigrate**: App Designer database migration container
- **ds-dbmigrate**: Data Stream Designer database migration container
- **sm-dbmigrate**: Subscription Manager database migration container
- **ai-dbmigrate**: AI Designer database migration container (optional)

### Infrastructure Services
- **resource-group**: Azure resource group creation and management
- **storage-account**: Azure Storage for deployment artifacts
- **dns-zone**: Custom domain and DNS management
- **monitoring**: Application Insights and Log Analytics
- **key-vault**: Azure Key Vault for secrets management
- **sm-key-vault**: Specialized Key Vault for SM service

### Container Services
- **stream-host-container**: Stream processing runtime container
- **licenses-container**: License provisioning container (evaluation mode)
- **sm-prep-container**: SM deployment preparation container

## 🔄 Evaluation vs For Production Workloads

### Evaluation Mode (`is_evaluation_mode = true`)

**Purpose**: Quick setup for demos, trials, and evaluation environments.

**Features**:
- Deploys licenses container with predefined evaluation product IDs and keys
- Uses standardized evaluation settings for consistency
- Includes built-in license provisioning
- Suitable for proof-of-concept and demonstration scenarios

**Behavior**:
- Creates all infrastructure including licenses container
- Uses predefined product IDs: AD, DS, AI, and XMPro Notebook
- Configures evaluation licenses automatically
- **Forces company name to "Evaluation" (overrides any `company_name` variable value)**

> **⚠️ License Requirements**: To use a custom company name, you must:
> 1. Set `is_evaluation_mode = false`
> 2. Request licenses from XMPro for your specific company name
> 3. The evaluation licenses are only valid for the "Evaluation" company name

### For Production Workloads (`is_evaluation_mode = false`, default)

**Purpose**: Deployments for production workloads where customers provide their own licensing.

**Features**:
- Skips licenses container deployment
- Uses hardcoded fallback product IDs and keys
- Customer manages their own license provisioning
- Suitable for customer environments with existing licensing

**Behavior**:
- Creates infrastructure without licenses container
- Uses random UUIDs for product IDs (when not specified)
- Requires external license management
- Customer provides their own product configuration

### Migration Between Modes

To switch from evaluation to production workloads:

1. Set `is_evaluation_mode = false`
2. Provide your own product IDs via variables
3. Set up external license management
4. Apply the Terraform configuration

## 🗄️ Existing Database Support

The module supports reusing existing SQL Server and databases for flexible deployment scenarios:

### Configuration

```hcl
# Enable existing database mode
use_existing_database    = true
existing_sql_server_fqdn = "your-server.database.windows.net"

# Standard database and authentication settings
db_admin_username = "your-admin-username"
db_admin_password = "your-admin-password"
```

### Behavior When Using Existing Database

**Skipped Resources**:
- SQL Server and database creation
- Database migration containers (sm-dbmigrate, ad-dbmigrate, ds-dbmigrate)
- Licenses container deployment

**Created Resources**:
- All App Services with existing database connectivity
- Monitoring and supporting infrastructure
- Stream Host and other container services

### Requirements for Existing Database

1. **Database Names**: Must contain databases named `AD`, `DS`, `SM`, and optionally `AI`
2. **Firewall Rules**: Must allow connections from the newly created Azure resources
3. **Schema Compatibility**: Database schemas should be compatible with the specified `imageversion`
4. **Authentication**: Provided credentials must have sufficient privileges

### Warnings and Considerations

- Ensure firewall rules allow connections from new App Services and Container Instances
- Database migration containers are skipped, so schema must be pre-configured
- Variables like `company_name`, product IDs, and URLs should match existing database values

## Stream Host Variants

The Stream Host container supports multiple Docker image variants. Use the `stream_host_variant` variable to select a variant:

```hcl
# Example: Using Python variant for pip package installation
stream_host_variant = "bookworm-slim-python3.12"
```

For detailed information about available variants and their capabilities, see the [Stream Host Docker Variants documentation](https://documentation.xmpro.com/4.5/src/installation/install-stream-host/docker.html#available-variants).

**Important**: Python package installation environment variables (`SH_PIP_MODULES`, `PIP_REQUIREMENTS_PATH`) are only available with the `bookworm-slim-python3.12` variant.

## 🏗️ Infrastructure Requirements

### Azure Permissions

The deploying user/service principal requires the following Azure permissions:

- **Contributor** role on the target subscription or resource group
- **User Access Administrator** role (for Key Vault access policies)
- **DNS Zone Contributor** role (if using custom domains)

### Resource Quotas

Ensure your Azure subscription has sufficient quotas for:

- **App Service Plans**: 4 instances (SM, AD, DS, AI)
- **SQL Databases**: 4 databases (SM, AD, DS, AI)
- **Container Instances**: 5-7 instances (depending on configuration)
- **Storage Accounts**: 1 instance
- **Key Vaults**: 2 instances

### Network Requirements

- **Outbound Internet Access**: Required for container image pulls and API communication
- **Azure Service Communication**: App Services must communicate with SQL Database and Key Vault
- **Custom Domain Access**: If using custom domains, DNS must be properly configured

## 🚨 Troubleshooting

### Common Issues

#### 1. Container Image Pull Failures

**Symptoms**: Container instances fail to start with image pull errors

**Solutions**:
- Verify `acr_url_product`, `acr_username`, and `acr_password` are correct
- Ensure the specified `imageversion` exists in the registry
- Check `is_private_registry` setting matches your registry configuration

#### 2. Database Connection Failures

**Symptoms**: App Services cannot connect to database

**Solutions**:
- Verify `db_admin_username` and `db_admin_password` are correct
- Check SQL Server firewall rules allow Azure services
- When using existing database, ensure firewall allows new resource IPs

#### 3. DNS Resolution Issues

**Symptoms**: Custom domains not resolving correctly

**Solutions**:
- Verify DNS zone delegation is properly configured
- Check that `dns_zone_name` matches your actual DNS zone
- Ensure DNS records are propagated (can take up to 48 hours)

#### 4. Key Vault Access Denied

**Symptoms**: Application cannot access Key Vault secrets

**Solutions**:
- Verify the deploying user has sufficient permissions
- Check Azure AD tenant configuration
- Ensure Managed Identity is properly configured for App Services

#### 5. Stream Host Connection Issues

**Symptoms**: Stream Host cannot connect to DS service

**Solutions**:
- Verify `ds_url` configuration is correct
- Check network connectivity between container instances and App Services
- Validate stream host collection ID and secret configuration

### Debugging Steps

1. **Check Resource Group**: Verify all expected resources are created
2. **Review Activity Log**: Check Azure Activity Log for deployment errors
3. **Examine Container Logs**: Use Azure Portal to view container instance logs
4. **Test Connectivity**: Verify network connectivity between services
5. **Validate Configuration**: Check environment variables in App Service configuration

### Terraform State Issues

If you encounter Terraform state issues:

```bash
# Refresh state
terraform refresh

# Import existing resources (if needed)
terraform import azurerm_resource_group.main /subscriptions/{subscription-id}/resourceGroups/{rg-name}

# Force recreation of problematic resources
terraform taint module.problematic_module.resource_name
terraform apply
```

## 🤝 Contributing

We welcome contributions to improve this Terraform module! Please follow these guidelines:

### Development Setup

1. **Clone the repository**
2. **Install prerequisites**: Terraform, Azure CLI
3. **Set up authentication**: Configure Azure credentials
4. **Create test environment**: Use a dedicated Azure subscription for testing

### Testing Changes

1. **Validate syntax**: `terraform validate`
2. **Check formatting**: `terraform fmt -check`
3. **Plan deployment**: `terraform plan`
4. **Test deployment**: Deploy to test environment
5. **Verify functionality**: Test all XMPro services

### Submission Guidelines

1. **Create feature branch** from main
2. **Make focused changes** with clear descriptions
3. **Update documentation** for any new variables or outputs
4. **Test thoroughly** in isolated environment
5. **Submit pull request** with detailed description

### Code Standards

- Follow Terraform best practices and conventions
- Use consistent naming patterns across resources
- Include comprehensive variable descriptions and validation
- Add appropriate tags to all resources
- Document any breaking changes

## 📄 License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support with this Terraform module:

1. **Documentation**: Review the [XMPro public documentation](https://documentation.xmpro.com) for comprehensive guides and resources
2. **Enterprise Support**: Contact XMPro for commercial support options

---

**Terraform Module**: XMPro Azure Platform  
**Version**: Compatible with XMPro 4.5.x and later  
**Maintained By**: XMPro Platform Engineering Team