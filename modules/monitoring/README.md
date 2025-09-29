# Azure Monitoring Module

This module creates Azure monitoring resources including Log Analytics workspace and Application Insights for comprehensive monitoring of Azure resources.

## Usage

```hcl
module "monitoring" {
  source = "../modules/monitoring"
  
  company_name        = var.company_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### With Custom Names and Settings

```hcl
module "monitoring" {
  source = "../modules/monitoring"
  
  company_name        = var.company_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Log Analytics settings
  log_analytics_name  = "custom-logs-workspace"
  log_analytics_sku   = "PerGB2018"
  log_retention_days  = 60
  
  # Application Insights settings
  app_insights_name   = "custom-app-insights"
  application_type    = "web"
  
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
| resource_group_name | The name of the resource group in which to create the monitoring resources | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| enable_log_analytics | Whether to create a Log Analytics workspace | `bool` | `true` | no |
| log_analytics_name | The name of the Log Analytics workspace. If not provided, a name will be generated. | `string` | `""` | no |
| log_analytics_sku | The SKU of the Log Analytics workspace | `string` | `"PerGB2018"` | no |
| log_retention_days | The number of days to retain logs in the Log Analytics workspace | `number` | `30` | no |
| enable_app_insights | Whether to create an Application Insights instance | `bool` | `true` | no |
| app_insights_name | The name of the Application Insights instance. If not provided, a name will be generated. | `string` | `""` | no |
| application_type | The type of Application Insights to create | `string` | `"web"` | no |
| enable_app_insights_telemetry | Whether to enable Application Insights telemetry collection | `bool` | `true` | no |
| generate_random_suffix | Whether to generate a random suffix for resource names | `bool` | `false` | no |
| random_suffix_length | The length of the random suffix to generate | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_analytics_workspace_id | The ID of the Log Analytics workspace |
| log_analytics_workspace_name | The name of the Log Analytics workspace |
| log_analytics_primary_shared_key | The primary shared key for the Log Analytics workspace |
| app_insights_id | The ID of the Application Insights instance |
| app_insights_name | The name of the Application Insights instance |
| app_insights_connection_string | The connection string for the Application Insights instance |
| app_insights_instrumentation_key | The instrumentation key for the Application Insights instance |
| app_insights_app_id | The App ID of the Application Insights instance |
