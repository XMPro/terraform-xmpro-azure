
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
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "company_name" {
  description = "Company name used in resource naming"
  type        = string
  default     = "Evaluation"
}

variable "company_admin_first_name" {
  description = "First name of the company administrator"
  type        = string
  default     = "admin"
}

variable "company_admin_last_name" {
  description = "Last name of the company administrator"
  type        = string
  default     = "xmpro"
}

variable "company_admin_email_address" {
  description = "Email address of the company administrator"
  type        = string
  validation {
    condition     = var.company_admin_email_address == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.company_admin_email_address))
    error_message = "Email address must be a valid email format or empty string."
  }
}

variable "company_admin_username" {
  description = "Username for the company administrator (format: firstname.lastname@companyname.onxmpro.com)"
  type        = string
}

variable "is_private_registry" {
  description = "Whether to use private registry authentication for container images"
  type        = bool
  default     = false
}

variable "acr_url_product" {
  description = "The URL of the Azure Container Registry for product images"
  type        = string
}

variable "acr_username" {
  description = "The username for the Azure Container Registry (only required for private images)"
  type        = string
  default     = ""
}

variable "acr_password" {
  description = "The password for the Azure Container Registry (only required for private images)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_connection_string" {
  description = "The connection string for the SM database"
  type        = string
  sensitive   = true
}

variable "company_admin_password" {
  description = "The company admin password for Service Management"
  type        = string
  sensitive   = true
}

variable "ad_url" {
  description = "The URL for the AD application"
  type        = string
}

variable "ds_url" {
  description = "The URL for the DS application"
  type        = string
}

variable "ai_url" {
  description = "The URL for the AI application"
  type        = string
}

variable "nb_url" {
  description = "The URL for the NB application"
  type        = string
}

variable "imageversion" {
  description = "The version of the container image to use"
  type        = string
  default     = "4.4.19"
}

variable "sm_product_id" {
  description = "The product ID for SM, shared between modules"
  type        = string
}

variable "sm_database_id" {
  description = "The ID of the SM database, used to create an implicit dependency"
  type        = string
}

variable "site_admin_password" {
  description = "The site admin password for Service Management"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "deployment_suffix" {
  description = "Random suffix for ensuring unique resource names across deployments"
  type        = string
}

variable "product_ids" {
  description = "Map of product IDs for evaluation mode"
  type        = map(string)
  default = {
    ad = "fe011f90-5bb6-80ad-b0a2-56300bf3b65d"
    ai = "e0b6a43a-bdd3-13ba-ffba-4c889461a1f3"
    ds = "71435803-967a-e9ac-574c-face863f7ec0"
    nb = "3765f34c-ff4e-3cff-e24e-58ac5771d8c5"
  }
}

variable "product_keys" {
  description = "Map of product keys for evaluation mode"
  type        = map(string)
  default = {
    ad = "f27eeb2d-c557-281c-9d4c-fe44cfb74a97"
    ai = "950ca93b-1ad9-514b-4263-4d3f510012e2"
    ds = "f744911d-e8a6-f8fb-9665-61b185845d6a"
    nb = "383526ff-8d3f-5941-4bc8-482ed83152be"
  }
}

variable "is_evaluation_mode" {
  description = "Flag to indicate if the deployment is in evaluation mode"
  type        = bool
  default     = false
}
