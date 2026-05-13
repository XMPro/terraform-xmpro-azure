# AI Mags UI - Infrastructure Layer Configuration
# Environment: dev/ai-mags-ui branch

# ==========================================
# REQUIRED - Infrastructure settings
# ==========================================

# Core platform settings
company_name = "xmpro"
name_suffix  = "aimag8"
location     = "australiaeast"

# Database credentials
# NOTE: Actual passwords will be provided via TF_VAR_* environment variables from Key Vault in pipeline
db_admin_username = "xmadmin"
db_admin_password = "XmPr0!D3v@2026Mags"

# ==========================================
# OPTIONAL - Infrastructure tuning
# ==========================================

# App Service Plan configuration - Development SKUs
ad_service_plan_sku           = "B1" # Provided via TF_VAR_ad_service_plan_sku
ds_service_plan_sku           = "B1" # Provided via TF_VAR_ds_service_plan_sku
sm_service_plan_sku           = "B2" # Provided via TF_VAR_sm_service_plan_sku
ai_service_plan_sku           = "B1" # Provided via TF_VAR_ai_service_plan_sku
app_service_plan_worker_count = 1

# Storage configuration
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Database configuration
db_allow_all_ips           = true
create_local_firewall_rule = false

# Feature flags
enable_app_insights       = true
enable_log_analytics      = true
create_redis_cache        = false
enable_alerting           = false
create_masterdata         = false
enable_ai                 = true
enable_rbac_authorization = false

# DNS configuration
enable_custom_domain = false
dns_zone_name        = ""

# Networking
prod_networking_enabled = false

# Tags
tags = {
  Branch      = "dev/ai-mags-ui"
  Environment = "dev-aimag"
  ManagedBy   = "Terraform"
  Layer       = "Infrastructure"
}
