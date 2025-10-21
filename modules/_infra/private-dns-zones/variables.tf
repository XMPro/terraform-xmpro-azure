variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "dns_zones" {
  description = "Map of DNS zone configurations"
  type = map(object({
    name = string
  }))
}

variable "virtual_network_id" {
  description = "The ID of the virtual network to link to DNS zones"
  type        = string
  default     = null
}

variable "enable_auto_registration" {
  description = "Enable auto registration of virtual machine records in the DNS zone"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}