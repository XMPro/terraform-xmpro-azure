# XMPro Stream Host Example

This example demonstrates how to deploy an XMPro Stream Host container using Terraform. The Stream Host is a lightweight component that connects to an existing XMPro Data Stream Designer instance to run stream processing workloads.

## Overview

This deployment creates:
- Resource Group
- Stream Host Container Instance (Azure Container Instances)
- Necessary networking and security configurations

## Prerequisites

1. An existing XMPro Data Stream Designer instance
2. Collection ID and Secret from your DS instance
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
   # Copy the example variables file
   cp terraform.tfvars.example terraform.tfvars
   
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
imageversion = "4.5.0"
```

## Optional Configuration

### Resource Allocation

```hcl
# CPU and memory allocation
stream_host_cpu = 1        # Between 0.25 and 4 cores
stream_host_memory = 4     # Between 0.5 and 16 GB
```

### Private Registry

If using private container images:

```hcl
is_private_registry = true
acr_username = "your-registry-username"
acr_password = "your-registry-password"
```

### Monitoring Integration

```hcl
# Application Insights
app_insights_connection_string = "InstrumentationKey=your-key"

# Log Analytics
log_analytics_workspace_id = "your-workspace-id"
log_analytics_primary_shared_key = "your-workspace-key"
```

### Custom Environment Variables

```hcl
environment_variables = {
  "CUSTOM_SETTING" = "value"
  "LOG_LEVEL" = "Debug"
}
```

### Volume Mounts

```hcl
volumes = [
  {
    name       = "config-volume"
    mount_path = "/app/config"
    read_only  = true
    secret = {
      "config.json" = base64encode(file("./config.json"))
    }
  }
]
```

## Outputs

After deployment, the following outputs are available:

- `resource_group_name` - Name of the created resource group
- `stream_host_container_group_id` - ID of the Stream Host container group
- `stream_host_container_group_name` - Name of the Stream Host container group

## Getting Collection Credentials

To obtain the required collection credentials:

1. Open your XMPro Data Stream Designer
2. Navigate to **Collections**
3. Select or create a collection for the Stream Host
4. Go to **Settings** tab
5. Copy the **Collection ID** and **Collection Secret**

## Troubleshooting

### Container Won't Start

1. **Check DS URL**: Ensure `ds_server_url` is accessible from Azure
2. **Verify Credentials**: Confirm collection ID and secret are correct
3. **Check Logs**: Use Azure portal to view container logs
4. **Network Access**: Ensure firewall allows outbound HTTPS connections

### Connection Issues

```bash
# Check container logs
az container logs --resource-group <resource-group> --name <container-name>

# Check container status
az container show --resource-group <resource-group> --name <container-name>
```

### Resource Constraints

If the container is running out of resources:

```hcl
# Increase CPU/memory allocation
stream_host_cpu = 2
stream_host_memory = 8
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