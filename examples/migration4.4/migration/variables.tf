variable "company_name" {
  type = string
}

variable "name_suffix" {
  type = string
}

variable "resource_group_name" {
  description = "New 4.6 RG (from infra layer). The helper ACI runs here."
  type        = string
}

variable "existing_sql_server_fqdn" {
  description = "FQDN of the existing 4.4 SQL Server."
  type        = string
}

variable "db_admin_username" {
  type      = string
  sensitive = true
}

variable "db_admin_password" {
  description = "Supply via TF_VAR_db_admin_password."
  type        = string
  sensitive   = true
}

variable "sm_database_name" {
  type    = string
  default = "SM"
}

variable "ad_database_name" {
  type    = string
  default = "AD"
}

variable "ds_database_name" {
  type    = string
  default = "DS"
}

variable "ad_url" {
  description = "New 4.6 App Designer URL (app layer output)."
  type        = string
}

variable "ds_url" {
  description = "New 4.6 Data Stream Designer URL (app layer output)."
  type        = string
}

variable "ai_url" {
  description = "New 4.6 AI URL. Empty string skips AI."
  type        = string
  default     = ""
}

variable "nb_url" {
  description = "Notebook URL. Empty string skips."
  type        = string
  default     = ""
}

variable "prod_networking_enabled" {
  type    = bool
  default = false
}

variable "vnet_name" {
  description = "Required when prod_networking_enabled = true."
  type        = string
  default     = ""
}

variable "subnet_names" {
  description = "Required when prod_networking_enabled = true. Only aci is read."
  type = object({
    presentation = string
    data         = string
    aci          = string
    processing   = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
