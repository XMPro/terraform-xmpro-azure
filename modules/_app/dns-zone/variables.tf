# Application DNS Configuration Variables

variable "dns_zone_name" {
  description = "Name of the existing DNS zone (created by infrastructure layer)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "domain_verification_records" {
  description = "Map of domain verification records"
  type = map(object({
    verification_id = string
  }))
  default = {}
}

variable "cname_records" {
  description = "Map of CNAME records to create"
  type = map(object({
    record = string
  }))
  default = {}
}

variable "hostname_bindings" {
  description = "Map of hostname bindings to create"
  type = map(object({
    app_service_name = string
  }))
  default = {}
}

variable "record_ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}