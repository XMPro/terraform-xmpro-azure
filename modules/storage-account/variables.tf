variable "name_prefix" {
  description = "The prefix for the storage account name when using random suffix"
  type        = string
  default     = "st"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account"
  type        = string
}

variable "location" {
  description = "The Azure location where the storage account should be created"
  type        = string
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
      "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope",
      "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "uksouth", "ukwest",
      "eastasia", "southeastasia", "australiaeast", "australiasoutheast", "centralindia", "southindia",
      "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "account_tier" {
  description = "The tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type of the storage account (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "The kind of storage account (StorageV2, Storage, BlobStorage, FileStorage, BlockBlobStorage)"
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "The access tier of the storage account (Hot or Cool)"
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "The minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "tags" {
  description = "A mapping of tags to assign to the storage account"
  type        = map(string)
  default     = {}
}

variable "file_shares" {
  description = "A map of file shares to create in the storage account"
  type = map(object({
    quota = number
  }))
  default = {}
}

