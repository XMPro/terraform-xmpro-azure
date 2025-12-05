variable "name" {
  description = "Name of the private endpoint"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where private endpoint will be created"
  type        = string
}

variable "app_service_id" {
  description = "App Service resource ID"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for App Services (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the private endpoint"
  type        = map(string)
  default     = {}
}
