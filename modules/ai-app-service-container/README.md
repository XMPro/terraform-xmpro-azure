# XMPro AI App Service Container Module

This Terraform module creates an Azure App Service container for the XMPro AI application with integrated Key Vault for secure configuration management.

## Purpose

The AI app service container is responsible for:
- Hosting the XMPro AI application in a Linux container
- Providing AI/ML capabilities and services for the XMPro platform
- Managing health checks and monitoring for AI services
- Integrating with other XMPro components (AD, DS, SM)
- Secure configuration management via Azure Key Vault

## Features

- **Linux Web App**: Container-based hosting on Azure App Service
- **Key Vault Integration**: Secure storage and retrieval of sensitive configuration
- **Health Checks**: Comprehensive health monitoring and endpoints
- **Auto-scaling**: Configurable App Service Plan for scaling requirements
- **Security**: HTTPS-only, system-assigned managed identity, TLS 1.2 minimum
- **Monitoring**: Application Insights integration for telemetry
- **Registry Authentication**: Support for private Azure Container Registry

## Usage

```hcl
module "ai_app_service_container" {
  source = "../../modules/ai-app-service-container"

  name_suffix         = var.name_suffix
  location            = var.location
  resource_group_name = module.resource_group.name
  companyname         = var.companyname

  # Container Registry
  acr_url_product     = var.acr_url_product
  is_private_registry = var.is_private_registry
  acr_username        = var.acr_username
  acr_password        = var.acr_password

  # Database Configuration
  db_connection_string = module.database.ai_db_connection_string

  # Application URLs
  ad_url = module.ad_app_service_container.app_url
  sm_url = module.sm_app_service.app_url
  ds_url = module.ds_app_service_container.app_url
  ai_url = "https://ai-${var.companyname}-${var.environment}.azurewebsites.net"

  # Monitoring
  app_insights_connection_string = module.monitoring.app_insights_connection_string

  # Container Configuration
  service_plan_sku        = var.service_plan_sku
  docker_image_name       = "ai:${var.imageversion}"
  aspnetcore_environment  = var.aspnetcore_environment

  # Dependencies
  aidbmigrate_container_id = module.ai_dbmigrate.container_group_id
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_suffix | Random suffix to append to resource names | `string` | n/a | yes |
| location | The Azure location where all resources should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| companyname | Company name used in resource naming | `string` | n/a | yes |
| acr_url_product | The URL of the Azure Container Registry | `string` | n/a | yes |
| is_private_registry | Whether to use private registry authentication | `bool` | `false` | no |
| acr_username | The username for the Azure Container Registry | `string` | `""` | no |
| acr_password | The password for the Azure Container Registry | `string` | `""` | no |
| db_connection_string | The connection string for the AI database | `string` | n/a | yes |
| ad_url | The URL for the AD application | `string` | n/a | yes |
| sm_url | The URL for the SM application | `string` | n/a | yes |
| ds_url | The URL for the DS application | `string` | n/a | yes |
| ai_url | The URL for the AI application | `string` | n/a | yes |
| app_insights_connection_string | The connection string for Application Insights | `string` | n/a | yes |
| service_plan_sku | The SKU of the App Service Plan | `string` | `"B1"` | no |
| docker_image_name | The name of the Docker image to use | `string` | `"ai:4.4.19-pr-2606"` | no |
| aspnetcore_environment | The ASP.NET Core environment to use | `string` | `"dev"` | no |
| aidbmigrate_container_id | The ID of the AI database migration container | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| app_name | The name of the AI app service |
| app_url | The URL of the AI app service |
| app_id | The ID of the AI app service |
| key_vault_id | The ID of the AI key vault |
| key_vault_name | The name of the AI key vault |
| service_plan_id | The ID of the AI service plan |
| service_plan_name | The name of the AI service plan |
| key_vault_secret_ids | Map of secret names to their IDs in the AI key vault |
| app_service_default_hostname | The default hostname of the AI app service |
| app_service_custom_domain_verification_id | The custom domain verification ID for the AI app service |

## Dependencies

This module depends on:
- Resource Group module (for resource group name)
- Database module (for AI database connection string)
- Monitoring module (for Application Insights connection string)
- AI DB Migration module (for database initialization)

## Key Vault Secrets

The module creates the following secrets in the AI Key Vault:
- `xmpro--xmsettings--data--connectionString`: AI database connection string
- `xmpro--data--connectionString`: AI database connection string
- `xmpro--xmidentity--client--id`: AI product ID for authentication
- `xmpro--xmidentity--client--sharedkey`: AI product shared key for authentication
- `ApplicationInsights--ConnectionString`: Application Insights connection string

## Configuration

The AI application is configured with:
- **Feature Flags**: Application Insights telemetry, health checks, and logging enabled
- **Health Checks**: Monitoring endpoints for SM, DS, and AD services
- **Identity Integration**: XMPro Identity server authentication
- **Database Migration**: Database migration feature flag (disabled by default)

## Notes

- The container uses the AI product ID: `b7be889b-01d3-4bd2-95c6-511017472ec8`
- The container uses the AI product key: `950ca93b-1ad9-514b-4263-4d3f510012e2`
- System-assigned managed identity is used for Key Vault access
- The app service runs on port 5000 inside the container
- All sensitive configuration is stored in Azure Key Vault
- The module establishes an implicit dependency on the AI database migration container