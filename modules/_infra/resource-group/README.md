# Azure Resource Group Module

This module creates an Azure Resource Group, which is a container that holds related resources for an Azure solution.

## Usage

```hcl
module "resource_group" {
  source = "../modules/resource-group"
  
  name     = "rg-${var.prefix}-${var.environment}-${var.location}"
  location = var.location
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the resource group | `string` | n/a | yes |
| location | The Azure location where the resource group should be created | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resource group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | The name of the resource group |
| location | The location of the resource group |
| id | The ID of the resource group |
