variable "key_vault_name" {
  description = "The name of the existing Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group containing the Key Vault"
  type        = string
}

variable "secrets" {
  description = "Map of secret names to values"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to the secrets"
  type        = map(string)
  default     = {}
}