variable "name" {
  description = "The name of the DNS Zone"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the DNS Zone"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the DNS Zone"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "The prefix to use for the DNS zone name when using random suffix"
  type        = string
  default     = ""
}

variable "record_ttl" {
  description = "The Time To Live (TTL) of the DNS records in seconds"
  type        = number
  default     = 300
}

variable "domain_verification_records" {
  description = "Map of domain verification TXT records to create"
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
  description = "Map of hostname bindings to create for app services"
  type = map(object({
    app_service_name = string
  }))
  default = {}
}
