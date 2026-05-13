# release-4.6.1 MAGS - Infrastructure Layer Configuration
# WI 24059 - Deployed via OIDC to XMPro Main DevTest Plan subscription
# Pipeline: deploy/_templates/deploy-rel461mags.yml

# ==========================================
# REQUIRED - Infrastructure settings
# ==========================================

# Core platform settings
company_name = "xmpro"
name_suffix  = "r461m"
location     = "australiaeast"

# Database credentials
# NOTE: Actual passwords will be provided via TF_VAR_* environment variables from terraform-dev-oidc variable group
db_admin_username = "xmadmin"
# db_admin_password = "" # Provided via TF_VAR_db_admin_password

# ==========================================
# OPTIONAL - Infrastructure tuning
# ==========================================

# App Service Plan configuration - Development SKUs
ad_service_plan_sku           = "B1"
ds_service_plan_sku           = "B1"
sm_service_plan_sku           = "B2"
ai_service_plan_sku           = "B1"
app_service_plan_worker_count = 1

# Storage configuration
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Database configuration
# Azure App Services / ACI in the same sub reach SQL via the module's
# always-on `FirewallRule-AllowAzureServices` rule, so we don't need the
# 0.0.0.0-255.255.255.255 internet-wide allow. Add specific IPs via
# db_firewall_rules if a developer needs direct laptop access.
db_allow_all_ips           = false
create_local_firewall_rule = false

# Feature flags
enable_app_insights  = true
enable_log_analytics = true
create_redis_cache   = false
enable_alerting      = false
create_masterdata    = false
enable_ai            = true

# DNS configuration
enable_custom_domain = true
dns_zone_name        = "rel461mags.dev.xmpro.com"

# Networking
prod_networking_enabled = false

# Tags
tags = {
  Branch      = "release-4.6.1"
  Environment = "dev-rel461mags"
  ManagedBy   = "Terraform"
  Layer       = "Infrastructure"
  WorkItem    = "24059"
}
