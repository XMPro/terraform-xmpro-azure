# Sandbox SM-Only Environment Variables

variable "companyname" {
  description = "Company identifier for resource naming"
  type        = string
  default     = "xmcompany"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "smsandbox"
}

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "australiaeast"
}

variable "db_admin_username" {
  description = "Database administrator username"
  type        = string
  default     = "sqladmin"
}

variable "db_admin_password" {
  description = "Database administrator password"
  type        = string
  default     = "SecurePassword123!"
  sensitive   = true
}

variable "company_admin_password" {
  description = "SM company admin password"
  type        = string
  default     = "CompanyAdmin123!"
  sensitive   = true
}

variable "site_admin_password" {
  description = "SM site admin password"
  type        = string
  default     = "SiteAdmin123!"
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL for SM source code"
  type        = string
  default     = "https://github.com/XMPro/xmpro-windows-installer"
}

variable "github_release_version" {
  description = "GitHub release version to deploy"
  type        = string
  default     = "v4.5.0.80-alpha-ede1ab6d70"
}

variable "github_token" {
  description = "GitHub personal access token for repository access (optional for public repos)"
  type        = string
  default     = ""
  sensitive   = true
}

# Tagging
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    "CreatedBy"      = "Terraform"
    "ManagedBy"      = "Platform Engineering"
    "Project"        = "XMPro Platform"
    "Keep_or_delete" = "Keep"
    "Billing"        = "SM-Only"
    "Purpose"        = "SM-only deployment example"
  }
}