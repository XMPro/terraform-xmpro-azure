# Azure Storage Account Module

This module creates an Azure Storage Account with optional containers, file shares, and files.

## Usage

```hcl
module "storage_account" {
  source = "../modules/storage-account"
  
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  
  # Optional: Specify a name directly (must be globally unique)
  name                     = "mystorageaccount"
  
  # Or use random suffix generation (recommended)
  generate_random_suffix   = true
  name_prefix              = "myapp"
  
  # Storage account configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  # Create blob containers
  containers = {
    "data" = {
      access_type = "private"
    },
    "public" = {
      access_type = "blob"
    }
  }
  
  # Create file shares
  file_shares = {
    "documents" = {
      quota = 5
    },
    "backups" = {
      quota = 10
    }
  }
  
  # Upload files to shares
  share_files = {
    "readme" = {
      name       = "README.md",
      share_name = "documents",
      source     = "${path.module}/files/README.md"
    }
  }
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the storage account | `string` | `""` | no |
| name_prefix | The prefix for the storage account name when using random suffix | `string` | `"st"` | no |
| generate_random_suffix | Whether to generate a random suffix for the storage account name | `bool` | `true` | yes |
| random_suffix_length | The length of the random suffix to generate | `number` | `8` | no |
| resource_group_name | The name of the resource group in which to create the storage account | `string` | n/a | yes |
| location | The Azure location where the storage account should be created | `string` | n/a | yes |
| account_tier | The tier of the storage account (Standard or Premium) | `string` | `"Standard"` | no |
| account_replication_type | The replication type of the storage account (LRS, GRS, RAGRS, ZRS) | `string` | `"LRS"` | no |
| account_kind | The kind of storage account (StorageV2, Storage, BlobStorage, FileStorage, BlockBlobStorage) | `string` | `"StorageV2"` | no |
| access_tier | The access tier of the storage account (Hot or Cool) | `string` | `"Hot"` | no |
| min_tls_version | The minimum TLS version for the storage account | `string` | `"TLS1_2"` | no |
| tags | A mapping of tags to assign to the storage account | `map(string)` | `{}` | no |
| containers | A map of containers to create in the storage account | `map(object({ access_type = string }))` | `{}` | no |
| file_shares | A map of file shares to create in the storage account | `map(object({ quota = number }))` | `{}` | no |
| share_files | A map of files to create in the file shares | `map(object({ name = string, share_name = string, source = string, content_type = optional(string), content_md5 = optional(string) }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the storage account |
| name | The name of the storage account |
| primary_access_key | The primary access key for the storage account |
| secondary_access_key | The secondary access key for the storage account |
| primary_connection_string | The primary connection string for the storage account |
| secondary_connection_string | The secondary connection string for the storage account |
| primary_blob_endpoint | The primary blob endpoint for the storage account |
| primary_file_endpoint | The primary file endpoint for the storage account |
| containers | Map of containers created in the storage account |
| file_shares | Map of file shares created in the storage account |
