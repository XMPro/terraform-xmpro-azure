# XMPro Stream Host Terraform Example

This example demonstrates how to deploy an XMPro Stream Host container on Azure using Terraform.

## Overview

This deployment creates:
- Resource Group (or uses existing)
- Stream Host Container Instance (Azure Container Instances)
- Necessary networking and security configurations

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
imageversion = "4.5.3"
```

## Optional Configuration

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

- `resource_group_name` - Name of the created resource group
- `stream_host_container_group_id` - ID of the Stream Host container group
- `stream_host_container_group_name` - Name of the Stream Host container group

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