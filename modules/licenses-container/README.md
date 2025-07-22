# XMPro Licenses Container Module

This Terraform module creates an Azure Container Group for XMPro license management and provisioning.

## Purpose

The licenses container is responsible for:
- Managing XMPro product licenses
- Provisioning licenses for AD, DS, AI, and SM products
- Setting up initial company and admin user configurations
- Executing license-related database operations

## Features

- **Container Group**: Single-instance Linux container
- **Database Integration**: Connects to SM database for license storage
- **Product License Management**: Handles multiple XMPro product licenses
- **Restart Policy**: Set to "Never" as this is a one-time provisioning container
- **Registry Authentication**: Supports private Azure Container Registry

## Usage

```hcl
module "licenses_container" {
  source = "../../modules/licenses-container"

  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name

  # Container Registry
  acr_url_product = var.acr_url_product
  acr_username    = var.acr_username
  acr_password    = var.acr_password

  # Database Configuration
  sql_server_fqdn    = module.database.sql_server_fqdn
  db_admin_username  = var.db_admin_username
  db_admin_password  = var.db_admin_password
  sm_database_id     = module.database.sm_database_id

  # Product IDs
  sm_product_id = var.sm_product_id
  ad_product_id = var.ad_product_id
  ds_product_id = var.ds_product_id
  ai_product_id = var.ai_product_id

  # License Keys
  ad_license = var.ad_license
  ds_license = var.ds_license
  ai_license = var.ai_license

  # Container Image
  imageversion = var.imageversion
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | The environment name for resource identification | `string` | n/a | yes |
| location | The Azure location where all resources should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| company_name | Company name used in resource naming | `string` | n/a | yes |
| deployment_suffix | Random suffix for unique resource names | `string` | n/a | yes |
| acr_url_product | The URL of the Azure Container Registry | `string` | n/a | yes |
| acr_username | The username for the Azure Container Registry | `string` | n/a | yes |
| acr_password | The password for the Azure Container Registry | `string` | n/a | yes |
| sql_server_fqdn | The FQDN of the SQL server | `string` | n/a | yes |
| db_admin_username | The admin username for the database | `string` | n/a | yes |
| db_admin_password | The admin password for the database | `string` | n/a | yes |
| sm_database_id | The ID of the SM database | `string` | n/a | yes |
| sm_product_id | The product ID for SM | `string` | n/a | yes |
| ad_product_id | The product ID for AD | `string` | n/a | yes |
| ds_product_id | The product ID for DS | `string` | n/a | yes |
| ai_product_id | The product ID for AI | `string` | n/a | yes |
| ad_license | The license key for AD | `string` | n/a | yes |
| ds_license | The license key for DS | `string` | n/a | yes |
| ai_license | The license key for AI | `string` | n/a | yes |
| company_id | The company ID for license provisioning | `number` | `2` | no |
| imageversion | The version of the container image to use | `string` | `"5.0.0-alpha"` | no |

## Outputs

| Name | Description |
|------|-------------|
| container_group_id | The ID of the licenses container group |
| container_group_name | The name of the licenses container group |
| container_ip_address | The IP address of the licenses container group |
| container_fqdn | The FQDN of the licenses container group |
| sm_product_id | The SM product ID |
| ad_product_id | The AD product ID |
| ds_product_id | The DS product ID |
| ai_product_id | The AI product ID |

## Dependencies

This module depends on:
- Resource Group module (for resource group name)
- Database module (for SQL server FQDN and database ID)

## Notes

- The container uses a "Never" restart policy as it's designed for one-time license provisioning
- Environment variables are configured to connect to the SM database
- The container establishes an implicit dependency on the database through the `sm_database_id` variable
- All sensitive variables (passwords, license keys) are marked as sensitive in Terraform