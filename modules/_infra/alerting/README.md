# Azure Alerting Module

This module creates Azure alerting resources including Action Groups and Alert Rules for comprehensive monitoring of Azure Container Instances, specifically targeting Stream Host containers.

## Usage

```hcl
module "stream_host_alerting" {
  source = "../modules/alerting"
  
  company_name        = var.company_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  container_group_id  = module.stream_host_container.container_group_id
  
  # Enable alerting
  enable_alerting = true
  enable_email_alerts = true
  alert_email_addresses = ["devops@mycompany.com"]
  
  # Configure container alerts
  enable_cpu_alerts = true
  cpu_alert_threshold = 80
  enable_memory_alerts = true
  memory_alert_threshold = 80
  enable_container_restart_alerts = true
  enable_container_stop_alerts = true
  
  # Container resource allocation for proper threshold calculation
  stream_host_cpu_cores = 1
  stream_host_memory_gb = 4
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

## Features

### Alert Types
- **CPU Usage Alerts**: Monitor container CPU utilization with configurable thresholds
- **Memory Usage Alerts**: Monitor container memory consumption with configurable thresholds
- **Container Restart Alerts**: Detect unexpected container restarts and notify administrators
- **Container Stop Alerts**: Monitor for container stop events and potential failures

### Notification Methods
- **Email**: Send alerts to multiple email addresses
- **SMS**: Send text message alerts to phone numbers  
- **Webhooks**: Integrate with external systems (Slack, Teams, PagerDuty, etc.)

### Configuration Options
- **Flexible Thresholds**: Configure CPU and memory usage percentage thresholds
- **Alert Severity**: Set appropriate severity levels for different alert types
- **Resource Awareness**: Automatically calculates thresholds based on allocated container resources
- **Customizable Windows**: Configure alert evaluation frequency and time windows

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| company_name | Company name for resource naming and identification | `string` | n/a | yes |
| environment | The environment name for resource identification | `string` | n/a | yes |
| location | The Azure location where all resources in this module should be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the alerting resources | `string` | n/a | yes |
| container_group_id | The ID of the container group to monitor (optional, enables container alerts when provided) | `string` | `null` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| enable_alerting | Master switch to enable or disable all alerting resources | `bool` | `false` | no |
| enable_email_alerts | Enable email notifications for alerts | `bool` | `false` | no |
| alert_email_addresses | List of email addresses to receive alert notifications | `list(string)` | `[]` | no |
| enable_sms_alerts | Enable SMS notifications for alerts | `bool` | `false` | no |
| alert_phone_numbers | List of phone numbers to receive SMS alert notifications | `list(string)` | `[]` | no |
| alert_phone_country_code | Country code for SMS alert phone numbers | `string` | `"1"` | no |
| enable_webhook_alerts | Enable webhook notifications for alerts | `bool` | `false` | no |
| alert_webhook_urls | List of webhook URLs to receive alert notifications | `list(string)` | `[]` | no |
| enable_cpu_alerts | Enable CPU usage alerts for containers | `bool` | `false` | no |
| cpu_alert_threshold | CPU usage percentage threshold for alerts | `number` | `80` | no |
| cpu_alert_severity | Severity level for CPU alerts (0-4, where 0 is critical) | `number` | `2` | no |
| stream_host_cpu_cores | Number of CPU cores allocated to the Stream Host container | `number` | `1` | no |
| enable_memory_alerts | Enable memory usage alerts for containers | `bool` | `false` | no |
| memory_alert_threshold | Memory usage percentage threshold for alerts | `number` | `80` | no |
| memory_alert_severity | Severity level for memory alerts (0-4, where 0 is critical) | `number` | `2` | no |
| stream_host_memory_gb | Memory in GB allocated to the Stream Host container | `number` | `4` | no |
| enable_container_restart_alerts | Enable container restart alerts | `bool` | `false` | no |
| enable_container_stop_alerts | Enable container stop alerts | `bool` | `false` | no |
| alert_window_size | The time window for metric alerts (ISO 8601 duration format) | `string` | `"PT5M"` | no |
| alert_evaluation_frequency | The evaluation frequency for metric alerts (ISO 8601 duration format) | `string` | `"PT1M"` | no |

## Outputs

| Name | Description |
|------|-------------|
| action_group_id | The ID of the action group for alerts |
| action_group_name | The name of the action group for alerts |
| container_cpu_alert_id | The ID of the container CPU alert rule (if enabled) |
| container_memory_alert_id | The ID of the container memory alert rule (if enabled) |
| container_restart_alert_id | The ID of the container restart alert rule (if enabled) |
| container_stop_alert_id | The ID of the container stop alert rule (if enabled) |

## Alert Severity Levels

- **0**: Critical - Immediate attention required
- **1**: Error - Prompt attention required  
- **2**: Warning - Attention may be required
- **3**: Informational - General information
- **4**: Verbose - Detailed information

## Container Metrics

The module monitors the following Azure Container Instance metrics:
- **CPU Usage**: `Microsoft.ContainerInstance/containerGroups/CpuUsage`
- **Memory Usage**: `Microsoft.ContainerInstance/containerGroups/MemoryUsage`
- **Container Events**: Activity log events for restart and stop operations

## Dependencies

This module requires:
- Resource group and location configuration
- **Application Insights ID** for alert rule creation (required parameter)
- Container group ID for monitoring (when container alerts are enabled)
- Proper Azure permissions to create Action Groups and Alert Rules

### Application Insights Dependency

**Critical**: The alerting module requires an Application Insights instance ID to function properly. You must provide this through the `app_insights_id` parameter.

**Options for providing Application Insights:**
1. **Internal Monitoring**: Use `enable_monitoring = true` to create App Insights automatically
2. **External App Insights**: Use `enable_monitoring = false` and provide `external_app_insights_id`

⚠️ **Validation**: If `enable_alerting = true`, you must ensure App Insights is available either through internal monitoring or external configuration.