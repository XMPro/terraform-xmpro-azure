variable "company_name" {
  description = "Company name for resource naming and identification"
  type        = string
}

variable "environment" {
  description = "The environment name for resource identification"
  type        = string
}

variable "location" {
  description = "The Azure location where all resources in this module should be created"
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

variable "resource_group_name" {
  description = "The name of the resource group in which to create the database resources"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "db_server_name" {
  description = "The name of the SQL server. If not provided, a name will be generated."
  type        = string
  default     = ""
}

variable "db_server_version" {
  description = "The version of the SQL server"
  type        = string
  default     = "12.0"
}

variable "administrator_login" {
  description = "The administrator login name for the SQL server"
  type        = string
}

variable "administrator_login_password" {
  description = "The administrator login password for the SQL server"
  type        = string
  sensitive   = true
}

variable "db_minimum_tls_version" {
  description = "The minimum TLS version for the SQL server"
  type        = string
  default     = "1.2"
}

# Firewall rules variables
variable "db_allow_azure_services" {
  description = "Whether to allow Azure services to access the SQL server"
  type        = bool
  default     = true
}

variable "db_allow_all_ips" {
  description = "Whether to allow all IPs to access the SQL server"
  type        = bool
  default     = false
}

variable "db_firewall_rules" {
  description = "A map of firewall rules to create on the SQL server"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

# Database variables
variable "databases" {
  description = "A map of databases to create on the SQL server"
  type = map(object({
    collation      = string
    max_size_gb    = number
    read_scale     = bool
    sku_name       = string
    zone_redundant = bool
    create_mode    = string
  }))
  default = {}
}

# Local Access Configuration
variable "create_local_firewall_rule" {
  description = "Flag to determine whether to create a firewall rule for local access"
  type        = bool
  default     = true
}