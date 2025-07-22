# SM App Service Module

This module creates the SM (Subscription Manager) application infrastructure, including Key Vault, App Service Plan, and App Service with standardized naming conventions.

## Features

- **Standardized Naming**: Implements consistent naming patterns for Azure resources
- **Character Limit Compliance**: Automatic truncation to meet Azure naming limits
- **Zone Redundancy**: App Service Plan configured for high availability
- **Key Vault Integration**: Automated certificate management and secret access
- **Flexible Configuration**: Optional name overrides for custom scenarios

## Naming Convention

### App Service Name Format
- **Pattern**: `app-<app_name>-<environment>-<name_suffix>`
- **Character Limit**: 60 characters (automatically truncated)
- **Example**: `app-sm-dev-abc123`

### App Service Plan Name Format
- **Pattern**: `plan-<app_name>-<environment>`
- **Character Limit**: 40 characters (automatically truncated) 
- **Example**: `plan-sm-dev`

## Usage

```hcl
module "sm_app_service" {
  source = "./modules/sm-app-service"

  # Required variables
  company_name        = "xmpro"
  environment         = "dev"
  resource_group_name = "rg-xmpro-dev"
  location            = "East US"
  company_name        = "MyCompany"
  name_suffix         = "abc123"
  app_name            = "sm"

  # Database configuration
  db_admin_username      = var.db_admin_username
  db_admin_password      = var.db_admin_password
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  sql_server_fqdn        = "sql-server.database.windows.net"

  # Container registry
  acr_url_product = "myregistry.azurecr.io"
  acr_username    = var.acr_username
  acr_password    = var.acr_password

  # Application URLs
  ad_url = "https://app-ad-dev-abc123.azurewebsites.net"
  ds_url = "https://app-ds-dev-abc123.azurewebsites.net"
  ai_url = "https://app-ai-dev-abc123.azurewebsites.net"
  nb_url = "https://app-nb-dev-abc123.azurewebsites.net"
  sm_url = "https://app-sm-dev-abc123.azurewebsites.net"

  # Optional naming overrides
  app_service_name_override      = ""  # Use standard naming
  app_service_plan_name_override = ""  # Use standard naming

  tags = {
    Environment = "dev"
    Project     = "XMPro"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Application name (ad, ds, sm, ai, nb) | `string` | `"sm"` | no |
| company_name | The company name used for all resources | `string` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| location | Azure location | `string` | n/a | yes |
| name_suffix | Random suffix for resource names | `string` | n/a | yes |
| app_service_name_override | Optional app service name override | `string` | `""` | no |
| app_service_plan_name_override | Optional app service plan name override | `string` | `""` | no |
| service_plan_sku | App Service plan SKU | `string` | `"B1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_name | The name of the SM app service |
| app_url | The URL of the SM app service |
| app_service_name_standard | The standardized app service name used |
| app_service_plan_name_standard | The standardized app service plan name used |
| naming_info | Information about naming convention applied |

## Naming Convention Details

### Character Limits
- **App Service**: 60 characters maximum (Azure limit)
- **App Service Plan**: 40 characters maximum (practical limit)

### Validation Rules
- **app_name**: Alphanumeric, 1-10 characters
- **Override names**: Must respect character limits

### Truncation Behavior
If the generated names exceed limits, they are automatically truncated:
- Names are truncated from the right
- The `naming_info` output indicates if truncation occurred

### Examples

| Scenario | App Name | Environment | Suffix | Result |
|----------|----------|-------------|---------|---------|
| Standard | sm | dev | abc123 | `app-sm-dev-abc123` |
| Long Environment | ad | development | xyz789 | `app-ad-development-xyz789` |
| Truncated | testapp | verylongenvironmentname | verylongsuffix | `app-testapp-verylongenvironmentname-verylongsuffix` (truncated to 60 chars) |

## Dependencies

This module depends on:
- `sm-key-vault` module for secret management
- `sm-app-deployment` module for application deployment

## Zone Redundancy

The App Service Plan is configured with `zone_redundant = true` for high availability across Azure availability zones.