# Private Endpoints Module Variables

variable "location" {
  description = "Azure region for the private endpoints"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where private endpoints will be created (typically data subnet)"
  type        = string
}

variable "private_endpoints" {
  description = "Map of private endpoints to create"
  type = map(object({
    name                = string
    resource_id         = string
    subresource_name    = string
    private_dns_zone_id = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the private endpoints"
  type        = map(string)
  default     = {}
}
