# XMPro Stream Host Terraform Example

This example demonstrates how to deploy an XMPro Stream Host container on Azure using Terraform.

## Overview

This deployment creates:
- Resource Group (or uses existing)
- Stream Host Container Instance (Azure Container Instances)
- Necessary networking and security configurations
- Optional monitoring and alerting infrastructure (Application Insights, Log Analytics, Action Groups)

## Documentation

For comprehensive Stream Host documentation, see:
- [Stream Host Overview](https://documentation.xmpro.com/installation/install-stream-host)
- [Docker Variants and Configuration](https://documentation.xmpro.com/installation/install-stream-host/docker#available-variants)
- [Azure Terraform Deployment](https://documentation.xmpro.com/installation/install-stream-host/azure-terraform)

## Prerequisites

1. An existing XMPro Data Stream Designer instance
2. Collection ID and Secret from your DS instance ([How to obtain](https://documentation.xmpro.com/installation/install-stream-host#download-the-connection-profile))
3. Terraform installed (version 1.0 or later)
4. Azure CLI installed and authenticated

## Quick Start

1. **Clone or copy this example**
   ```bash
   # If using the module from GitHub
   git clone https://github.com/XMPro/terraform-xmpro-azure.git
   cd terraform-xmpro-azure/examples/stream-host
   ```

2. **Configure variables**
   ```bash
   # Linux/Mac
   cp terraform.tfvars.example terraform.tfvars
   
   # Windows
   copy terraform.tfvars.example terraform.tfvars
   
   # Edit with your specific values
   nano terraform.tfvars
   ```

3. **Initialize and deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Configuration

### Stream Host Settings

You **must** provide these values in your `terraform.tfvars`:

```hcl
# URL of your Data Stream Designer instance
ds_server_url = "https://ds.yourcompany.com"

# Collection credentials from DS (found in DS > Collections > [Your Collection] > Settings)
stream_host_collection_id = "your-collection-id"
stream_host_collection_secret = "your-collection-secret"
```

### Basic Settings

```hcl
# Deployment settings
environment = "dev"
location = "southeastasia"
company_name = "mycompany"

# Image version
imageversion = "4.5.2"
```

## Optional Configuration

### Monitoring and Alerting

You can enable monitoring and alerting independently based on your needs:

#### Option 1: Enable Both (Recommended for new deployments)
```hcl
# Creates Application Insights and Log Analytics
enable_monitoring = true

# Enables alerting using the created monitoring infrastructure
enable_alerting = true

# Email notifications
enable_email_alerts = true
alert_email_addresses = ["admin@company.com", "ops@company.com"]

# Container-specific alerts
enable_cpu_alerts = true
cpu_alert_threshold = 80  # Percentage
enable_memory_alerts = true
memory_alert_threshold = 80  # Percentage
enable_container_restart_alerts = true
enable_container_stop_alerts = true
```

#### Option 2: Monitoring Only
```hcl
# Creates Application Insights and Log Analytics without alerting
enable_monitoring = true
```

#### Option 3: Alerting with External Monitoring
```hcl
# Monitoring should be set to false
enable_monitoring = false
# Use existing Application Insights for alerting
enable_alerting = true
external_app_insights_id = "/subscriptions/your-sub/resourceGroups/your-rg/providers/Microsoft.Insights/components/your-appinsights"

# Configure alerts as needed
enable_cpu_alerts = true
# ... other alert settings
```

#### Option 4: Complete External Monitoring (Container Telemetry + Alerting)
```hcl
# Disable internal monitoring completely
enable_monitoring = false

# External monitoring for container telemetry
existing_app_insights_connection_string = "InstrumentationKey=your-key;IngestionEndpoint=https://..."
existing_log_analytics_workspace_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.OperationalInsights/workspaces/xxx"
existing_log_analytics_primary_shared_key = "your-workspace-key"

# External monitoring for alerting
enable_alerting = true
external_app_insights_id = "/subscriptions/your-sub/resourceGroups/your-rg/providers/Microsoft.Insights/components/your-appinsights"
enable_cpu_alerts = true
# ... other alert settings
```

⚠️ **Important**: When `enable_alerting = true` and `enable_monitoring = false`, you **must** provide `external_app_insights_id`. Terraform will validate this requirement and throw an error if the App Insights dependency is not satisfied.

The alerting system provides:
- **CPU Usage Alerts**: When container CPU exceeds threshold
- **Memory Usage Alerts**: When container memory exceeds threshold  
- **Container Restart Alerts**: When container restarts unexpectedly
- **Container Stop Alerts**: When container stops
- **Multiple Notification Methods**: Email, SMS, and webhook notifications

### Resource Group Configuration

By default, a new resource group is created for the Stream Host deployment. You can use an existing resource group instead:

```hcl
# Use existing resource group
use_existing_resource_group = true
existing_resource_group_name = "my-existing-rg"
```

### Log Analytics Cost Control

When `enable_monitoring = true`, you can control Log Analytics daily ingestion costs:

```hcl
# Set daily quota to prevent unexpected charges (default: 1 GB)
log_analytics_quota = 5  # GB per day
```

⚠️ **Note**: Azure daily caps may not work reliably. Consider data filtering for better cost control.

### Other Configuration Options

See `terraform.tfvars.example` for all available options including:
- Docker image variants (bookworm-slim, bookworm-slim-python3.12, alpine3.21)
- Resource allocation (CPU/memory)
- Using existing resource groups
- Python package installation (for Python variant)
- Monitoring integration
- Custom environment variables
- Volume mounts

For detailed configuration options, refer to:
- [Docker Environment Variables](https://documentation.xmpro.com/installation/install-stream-host/docker#configuration)
- [Python Package Installation](https://documentation.xmpro.com/installation/install-stream-host/docker#python-package-installation)

## Outputs

After deployment, the following outputs are available:

### Core Outputs
- `resource_group_name` - Name of the created resource group
- `stream_host_container_group_id` - ID of the Stream Host container group
- `stream_host_container_group_name` - Name of the Stream Host container group

### Monitoring Outputs (when `enable_monitoring = true`)
- `app_insights_connection_string` - Application Insights connection string (sensitive)
- `app_insights_instrumentation_key` - Application Insights instrumentation key (sensitive)
- `log_analytics_workspace_id` - Log Analytics workspace ID

### Alerting Outputs (when `enable_alerting = true`)
- `action_group_id` - Action group ID for alert notifications

## Getting Collection Credentials

See [How to obtain Collection credentials](https://documentation.xmpro.com/installation/install-stream-host#download-the-connection-profile) in the documentation.

## Troubleshooting

For troubleshooting Stream Host connection issues, see:
- [Stream Host Troubleshooting](https://documentation.xmpro.com/installation/install-stream-host#troubleshooting)

To check container status and logs:
```bash
# Check container logs
az container logs --resource-group <resource-group> --name <container-name>

# Check container status
az container show --resource-group <resource-group> --name <container-name>
```

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Advanced Usage

### Multiple Stream Hosts

To deploy multiple Stream Hosts, create separate directories or use Terraform workspaces:

```bash
# Using workspaces
terraform workspace new stream-host-1
terraform workspace new stream-host-2

# Switch between workspaces
terraform workspace select stream-host-1
terraform apply -var="company_name=mycompany-sh1"
```

### Integration with Full Platform

This Stream Host can connect to a full XMPro platform deployed using the basic example:

```hcl
# Point to your full platform DS instance
ds_server_url = "https://ds-mycompany-dev-southeastasia.azurewebsites.net"
```

## Support

For issues and questions:
- Check the [XMPro Documentation](https://documentation.xmpro.com/)
- Review container logs in Azure Portal
- Verify network connectivity and credentials