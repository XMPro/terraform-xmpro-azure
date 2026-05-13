# AI Mags UI - Application Layer Configuration
# Environment: dev/ai-mags-ui branch
#
# IMPORTANT: Deploy infrastructure layer first
# cd ../infra && terraform apply -var-file=env/dev-ai-mags-ui.tfvars

# ============================================================================
# CORE CONFIGURATION
# ============================================================================

company_name = "xmpro"
name_suffix  = "aimag"

# ============================================================================
# INFRASTRUCTURE REFERENCES (existing resources in Azure)
# ============================================================================
# These values reference existing resources in rg-xmpro-dev-ai-mag-6f645a63

resource_group_name  = "rg-xmpro-dev-ai-mag-6f645a63"
storage_account_name = "stxmp6f645a63"
storage_sas_token    = ""  # Leave empty to auto-generate

sql_server_fqdn = "sqldb-xmpro-dev-ai-mag-6f645a63.database.windows.net"

# Service Plan Names (existing resources)
ad_service_plan_name = "plan-ad-xmpro-6f645a63"
ds_service_plan_name = "plan-ds-xmpro-6f645a63"
sm_service_plan_name = "plan-sm-xmpro-6f645a63"
ai_service_plan_name = "plan-ai-xmpro-6f645a63"

# Key Vault Names (existing resources)
ad_key_vault_name = "kv-ad-xmpro-6f645a63"
ds_key_vault_name = "kv-ds-xmpro-6f645a63"
sm_key_vault_name = "kv-sm-xmpro-6f645a63"
ai_key_vault_name = "kv-ai-xmpro-6f645a63"

# ============================================================================
# CREDENTIALS & SECRETS
# ============================================================================
# NOTE: All passwords provided via TF_VAR_* environment variables from Key Vault

# Container Registry
acr_url_product = "xmprononprod.azurecr.io"
acr_username    = ""  # Public registry
acr_password    = ""  # Public registry

# Database Credentials
db_admin_username = "xmadmin"
# db_admin_password = ""  # Provided via TF_VAR_db_admin_password

# Application Admin Credentials
# company_admin_password = ""  # Provided via TF_VAR_company_admin_password
# site_admin_password = ""  # Provided via TF_VAR_site_admin_password
ad_encryption_key = ""  # Auto-generate

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

# imageversion is provided via TF_VAR_imageversion from pipeline (XMPRO_VERSION_FULLNAME)
# This ensures each deployment uses the correct version from the build
is_evaluation_mode = true

# Nonprod SM.zip host. Branch builds publish to stxmprodev001's $web static
# site; the module default (download.app.xmpro.com) is the public/customer host
# and does not have these artifacts.
sm_zip_download_url = "stxmprodev001.z8.web.core.windows.net"

# Company Admin Details
company_admin_first_name    = "Admin"
company_admin_last_name     = "User"
company_admin_email_address = ""

# ============================================================================
# FEATURE FLAGS
# ============================================================================

enable_rbac_authorization = false  # Key Vaults use access policies, not RBAC
enable_ai                 = true
create_stream_host        = true
enable_custom_domain      = true
dns_zone_name             = "devaimagsui.dev.xmpro.com"
enable_auto_scale         = false
redis_connection_string   = ""
enable_email_notification = true

# ============================================================================
# SMTP CONFIGURATION
# ============================================================================

# smtp_server       = ""  # Provided via TF_VAR_smtp_server
# smtp_from_address = ""  # Provided via TF_VAR_smtp_from_address
# smtp_username     = ""  # Provided via TF_VAR_smtp_username
# smtp_password     = ""  # Provided via TF_VAR_smtp_password
smtp_port       = 587
smtp_enable_ssl = true

# ============================================================================
# SSO CONFIGURATION
# ============================================================================

sso_enabled = true
# sso_azure_ad_client_id  = ""  # Provided via TF_VAR_sso_azure_ad_client_id
# sso_azure_ad_secret     = ""  # Provided via TF_VAR_sso_azure_ad_secret
# sso_business_role_claim = ""  # Provided via TF_VAR_sso_business_role_claim
# sso_azure_ad_tenant_id  = ""  # Provided via TF_VAR_sso_azure_ad_tenant_id

# ============================================================================
# ADDITIONAL STREAM HOSTS
# ============================================================================

stream_hosts = {}

# ============================================================================
# MONITORING (existing resources)
# ============================================================================

log_analytics_workspace_name = "log-xmpro-dev-ai-mag-australiaeast"
app_insights_name            = "appinsights-xmpro-dev-ai-mag"

# ============================================================================
# NETWORKING
# ============================================================================

prod_networking_enabled = false

# ============================================================================
# TAGS
# ============================================================================

keep_or_delete_tag = "keep"
billing_tag        = "development"
