# AI Mags UI - Application Layer Configuration
# Environment: dev/ai-mags-ui branch
#
# IMPORTANT: Deploy infrastructure layer first
# cd ../infra && terraform apply -var-file=env/dev-ai-mags-ui.tfvars

# ============================================================================
# CORE CONFIGURATION
# ============================================================================

company_name = "xmpro"
name_suffix  = "aimag8"

# ============================================================================
# INFRASTRUCTURE REFERENCES (from infra layer output with aimag8 suffix)
# ============================================================================

resource_group_name  = "rg-xmpro-aimag8"
storage_account_name = "stxmpaimag8"
storage_sas_token    = "" # Leave empty to auto-generate

sql_server_fqdn = "sql-xmpro-aimag8.database.windows.net"

# Service Plan Names
ad_service_plan_name = "plan-ad-xmpro-aimag8"
ds_service_plan_name = "plan-ds-xmpro-aimag8"
sm_service_plan_name = "plan-sm-xmpro-aimag8"
ai_service_plan_name = "plan-ai-xmpro-aimag8"

# Key Vault Names
ad_key_vault_name = "kv-ad-xmpro-aimag8"
ds_key_vault_name = "kv-ds-xmpro-aimag8"
sm_key_vault_name = "kv-sm-xmpro-aimag8"
ai_key_vault_name = "kv-ai-xmpro-aimag8"

# ============================================================================
# CREDENTIALS & SECRETS
# ============================================================================

# Container Registry
acr_url_product = "xmprononprod.azurecr.io"
acr_username    = "" # Public registry
acr_password    = "" # Public registry

# Database Authentication
enable_sql_aad_auth = false # Use SQL auth, not AAD

# Database Credentials
db_admin_username = "xmadmin"
db_admin_password = "XmPr0!D3v@2026Mags"

# Application Admin Credentials
company_admin_password = "XmPr0!Adm1n@2026"
site_admin_password    = "XmPr0!S1te@2026"
ad_encryption_key      = "" # Auto-generate

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

# imageversion from version.json on dev/ai-mags-ui branch
imageversion       = "5.0.0-dev-ai-mags-ui-pr-5170"
sm_zip_version     = "5.0.0-dev-ai-mags-ui"
is_evaluation_mode = true

# Company Admin Details
# Login username format: first.last@{company_name}.onxmpro.com (e.g. admin.user@xmpro.onxmpro.com)
company_admin_first_name    = "Admin"
company_admin_last_name     = "User"
company_admin_email_address = ""

# ============================================================================
# FEATURE FLAGS
# ============================================================================

enable_rbac_authorization = false
enable_ai                 = true
create_stream_host        = true

enable_custom_domain      = false
dns_zone_name             = ""
enable_auto_scale         = false
redis_connection_string   = ""
enable_email_notification = false

# ============================================================================
# SMTP CONFIGURATION
# ============================================================================

smtp_port       = 587
smtp_enable_ssl = true

# ============================================================================
# SSO CONFIGURATION
# ============================================================================

sso_enabled = false

# ============================================================================
# ADDITIONAL STREAM HOSTS
# ============================================================================

stream_hosts = {}

# ============================================================================
# MONITORING (from infra layer output with aimag8 suffix)
# ============================================================================

log_analytics_workspace_name = "log-xmpro-aimag8"
app_insights_name            = "appinsights-xmpro-aimag8"

# ============================================================================
# NETWORKING
# ============================================================================

prod_networking_enabled = false

# ============================================================================
# TAGS
# ============================================================================

keep_or_delete_tag = "keep"
billing_tag        = "development"
