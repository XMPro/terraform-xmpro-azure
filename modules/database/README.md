# Azure Database Module

This module creates Azure SQL Server and databases, with support for using existing SQL servers and configuring firewall rules.

## Usage

### Creating a new SQL Server with databases

```hcl
module "database" {
  source = "../modules/database"
  
  company_name        = var.company_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # SQL Server configuration
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  
  # Create databases
  databases = {
    "AD" = {
      collation      = "SQL_Latin1_General_CP1_CI_AS"
      max_size_gb    = 1
      read_scale     = false
      sku_name       = "Basic"
      zone_redundant = false
      create_mode    = "Default"
    },
    "DS" = {
      collation      = "SQL_Latin1_General_CP1_CI_AS"
      max_size_gb    = 1
      read_scale     = false
      sku_name       = "Basic"
      zone_redundant = false
      create_mode    = "Default"
    }
  }
  
  # Firewall rules
  allow_azure_services = true
  firewall_rules = {
    "AllowMyIP" = {
      start_ip_address = "203.0.113.1"
      end_ip_address   = "203.0.113.1"
    }
  }
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company_name | The company name used for all resources in this module | `string` | n/a | yes |
| environment | The environment name for resource identification | `string` | n/a | yes |
| location | The Azure location where all resources in this module should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the database resources | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| server_name | The name of the SQL server. If not provided, a name will be generated. | `string` | `""` | no |
| server_version | The version of the SQL server | `string` | `"12.0"` | no |
| administrator_login | The administrator login name for the SQL server | `string` | n/a | yes |
| administrator_login_password | The administrator login password for the SQL server | `string` | n/a | yes |
| minimum_tls_version | The minimum TLS version for the SQL server | `string` | `"1.2"` | no |
| allow_azure_services | Whether to allow Azure services to access the SQL server | `bool` | `true` | no |
| firewall_rules | A map of firewall rules to create on the SQL server | `map(object({ start_ip_address = string, end_ip_address = string }))` | `{}` | no |
| databases | A map of databases to create on the SQL server | `map(object({ collation = string, max_size_gb = number, read_scale = bool, sku_name = string, zone_redundant = bool, create_mode = string }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| sql_server_id | The ID of the SQL server |
| sql_server_name | The name of the SQL server |
| sql_server_fqdn | The fully qualified domain name of the SQL server |
| sql_server_connection_string | The connection string for the SQL server |
| database_ids | Map of database names to their IDs |
| database_connection_strings | Map of database names to their connection strings |
