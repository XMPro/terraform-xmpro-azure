# XMPro SM Database Migration Module

This Terraform module creates an Azure Container Group for XMPro Service Management (SM) database migration and initial setup.

## Purpose

The SM database migration container is responsible for:
- Migrating and setting up the SM database schema
- Creating initial company and admin user configurations
- Configuring product IDs and keys for evaluation or production modes
- Setting up base URLs for all XMPro products (AD, DS, AI, Notebook)
- Executing one-time database initialization tasks

## Features

- **Container Group**: Single-instance Linux container with restart policy "Never"
- **Evaluation Mode Support**: Configurable evaluation mode with predefined product IDs/keys
- **Product Configuration**: Supports AD, DS, AI, SM, and XMPro Notebook products
- **Registry Authentication**: Supports private Azure Container Registry
- **Database Integration**: Connects to SM database for schema migration and setup

## Evaluation Mode Behavior

The module supports two deployment modes that determine how product IDs and keys are configured:

### Evaluation Mode (`is_evaluation_mode = true`, default)
- Uses predefined evaluation product IDs and keys from the `product_ids` and `product_keys` variables
- Configures the database with standardized evaluation settings
- Suitable for demos, trials, and evaluation environments
- Product IDs and keys are hardcoded for consistency across deployments

### Production Mode (`is_evaluation_mode = false`)
- Uses production product IDs and keys as fallbacks
- Suitable for customer deployments with their own licensing
- Provides consistent behavior across deployments
- Note: When `is_evaluation_mode = false`, the main module skips deploying the licenses container

## Usage

```hcl
module "sm_dbmigrate" {
  source = "../../modules/sm-dbmigrate"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex
  
  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry
  
  # Database configuration
  db_connection_string   = local.sm_connection_string
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  sm_database_id         = module.database.database_ids["SM"]
  
  # Company Admin Configuration
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address
  company_admin_username      = local.company_admin_username
  
  # URLs - use predefined URLs to avoid circular dependencies
  ad_url = local.ad_base_url
  ds_url = local.ds_base_url
  ai_url = local.ai_base_url
  nb_url = local.nb_base_url
  
  # Image version
  imageversion = var.imageversion

  # SM product ID
  sm_product_id = random_uuid.sm_id.result
  
  # Evaluation Mode Configuration
  is_evaluation_mode = var.is_evaluation_mode
  product_ids        = var.product_ids
  product_keys       = var.product_keys

  # Tags
  tags = var.tags
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | The environment name for resource identification | `string` | n/a | yes |
| location | The Azure location where all resources should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| company_name | Company name used in resource naming | `string` | `"Evaluation"` | no |
| deployment_suffix | Random suffix for unique resource names | `string` | n/a | yes |
| acr_url_product | The URL of the Azure Container Registry | `string` | n/a | yes |
| acr_username | The username for the Azure Container Registry | `string` | `""` | no |
| acr_password | The password for the Azure Container Registry | `string` | `""` | no |
| is_private_registry | Whether to use private registry authentication | `bool` | `false` | no |
| db_connection_string | The connection string for the SM database | `string` | n/a | yes |
| company_admin_password | The company admin password for Service Management | `string` | n/a | yes |
| site_admin_password | The site admin password for Service Management | `string` | n/a | yes |
| company_admin_first_name | First name of the company administrator | `string` | `"admin"` | no |
| company_admin_last_name | Last name of the company administrator | `string` | `"xmpro"` | no |
| company_admin_email_address | Email address of the company administrator | `string` | n/a | yes |
| company_admin_username | Username for the company administrator | `string` | n/a | yes |
| ad_url | The URL for the AD application | `string` | n/a | yes |
| ds_url | The URL for the DS application | `string` | n/a | yes |
| ai_url | The URL for the AI application | `string` | n/a | yes |
| nb_url | The URL for the NB application | `string` | n/a | yes |
| imageversion | The version of the container image to use | `string` | `"4.4.19"` | no |
| sm_product_id | The product ID for SM, shared between modules | `string` | n/a | yes |
| sm_database_id | The ID of the SM database for dependency | `string` | n/a | yes |
| is_evaluation_mode | Whether to use evaluation mode with predefined product IDs and keys | `bool` | `true` | no |
| product_ids | Map of product IDs for evaluation mode | `map(string)` | See defaults | no |
| product_keys | Map of product keys for evaluation mode | `map(string)` | See defaults | no |
| tags | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Default Product IDs (Evaluation Mode)

When `is_evaluation_mode = true`, the following default product IDs are used:

- **AD**: `fe011f90-5bb6-80ad-b0a2-56300bf3b65d`
- **AI**: `e0b6a43a-bdd3-13ba-ffba-4c889461a1f3`
- **DS**: `71435803-967a-e9ac-574c-face863f7ec0`
- **XMPro Notebook**: `3765f34c-ff4e-3cff-e24e-58ac5771d8c5`

## Outputs

| Name | Description |
|------|-------------|
| container_group_id | The ID of the SM database migration container group |
| container_group_name | The name of the SM database migration container group |

## Dependencies

This module depends on:
- Resource Group module (for resource group name)
- Database module (for connection string and database ID)
- Random UUID resources (for SM product ID)

## Notes

- The container uses a "Never" restart policy as it's designed for one-time database migration
- Environment variables configure connections to all XMPro products
- The container establishes an implicit dependency on the database through the `sm_database_id` variable
- All sensitive variables (passwords, connection strings) are marked as sensitive in Terraform
- Product IDs and keys switch between evaluation and production values based on `is_evaluation_mode`