# release-4.6.1 MAGS - Application Layer Configuration
# WI 24059 - Deployed via OIDC to XMPro Main DevTest Plan subscription
# Pipeline: deploy/_templates/deploy-rel461mags.yml
#
# IMPORTANT: Deploy infrastructure layer first, then update the resource
# names below from the infra terraform outputs before applying the app layer.

# ============================================================================
# CORE CONFIGURATION
# ============================================================================

company_name = "xmpro"
name_suffix  = "r461m"

# ============================================================================
# INFRASTRUCTURE REFERENCES (existing resources from infra layer)
# ============================================================================
# These are pipeline-substituted from infra terraform outputs via TF_VAR_*
# env vars set in deploy-rel461mags.yml. They MUST NOT be assigned here -
# `-var-file=` overrides TF_VAR_* in terraform precedence, so even an empty
# string would clobber the pipeline-injected value.
#
# Provided via TF_VAR_*:
#   resource_group_name, storage_account_name, sql_server_fqdn,
#   ad/ds/sm/ai_service_plan_name, ad/ds/sm/ai_key_vault_name

# ============================================================================
# CREDENTIALS & SECRETS
# ============================================================================
# NOTE: All passwords provided via TF_VAR_* environment variables from terraform-dev-oidc

# Container Registry
acr_url_product = "xmprononprod.azurecr.io"
acr_username    = "" # Public registry
acr_password    = "" # Public registry

# Database Credentials
db_admin_username = "xmadmin"
# db_admin_password = ""       # Provided via TF_VAR_db_admin_password

# Application Admin Credentials
# company_admin_password = ""  # Provided via TF_VAR_company_admin_password
# site_admin_password    = ""  # Provided via TF_VAR_site_admin_password
ad_encryption_key = "" # Auto-generate

# ============================================================================
# APPLICATION CONFIGURATION
# ============================================================================

# imageversion provided via TF_VAR_imageversion (XMPRO_VERSION_FULLNAME)
is_evaluation_mode = true

# Nonprod SM.zip host (branch builds publish to this $web static site)
sm_zip_download_url = "stxmprodev001.z8.web.core.windows.net"

# Company Admin Details
company_admin_first_name    = "Admin"
company_admin_last_name     = "User"
company_admin_email_address = ""

# ============================================================================
# FEATURE FLAGS
# ============================================================================

enable_rbac_authorization = true # Must match infra layer (defaults to true) - KVs created in RBAC mode
enable_ai                 = true
create_stream_host        = true
enable_custom_domain      = true
dns_zone_name             = "rel461mags.dev.xmpro.com"
enable_auto_scale         = false
redis_connection_string   = ""
enable_email_notification = true

# ============================================================================
# SMTP CONFIGURATION
# ============================================================================

# smtp_server / smtp_from_address / smtp_username / smtp_password provided via TF_VAR_*
smtp_port       = 587
smtp_enable_ssl = true

# ============================================================================
# SSO CONFIGURATION
# ============================================================================

sso_enabled = true
# sso_azure_ad_client_id / sso_azure_ad_secret / sso_business_role_claim / sso_azure_ad_tenant_id provided via TF_VAR_*

# ============================================================================
# ADDITIONAL STREAM HOSTS
# ============================================================================

stream_hosts = {}

# ============================================================================
# MONITORING (existing resources from infra layer)
# ============================================================================
# Provided via TF_VAR_log_analytics_workspace_name and TF_VAR_app_insights_name -
# do not assign here (would override pipeline value due to -var-file precedence).

# ============================================================================
# NETWORKING
# ============================================================================

prod_networking_enabled = false

# ============================================================================
# TAGS
# ============================================================================

keep_or_delete_tag = "keep"
billing_tag        = "development"
