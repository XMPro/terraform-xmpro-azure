# XMTwin 4.4 -> 4.6 migration - APPLICATION LAYER
# Points new 4.6 app services at XMTwin's existing prod SQL.
# Sensitive values + infra references are pipeline-injected via TF_VAR_*
# (see deploy-twin.yml). -var-file precedence means do NOT uncomment the
# commented blocks below; they'd clobber the TF_VAR_* values.

company_name = "xmtwin"
name_suffix  = "twin01"

# Infra references - injected from infra-stage outputs via TF_VAR_*:
# resource_group_name, storage_account_name, sql_server_fqdn,
# {ad,ds,sm,ai}_service_plan_name, {ad,ds,sm,ai}_key_vault_name,
# log_analytics_workspace_name, app_insights_name

use_existing_database    = true
existing_sql_server_fqdn = "xmtwin-sqlserver-mndr6zvfog2xi.database.windows.net"

# Product IDs/Keys - injected via TF_VAR_* from terraform-dev-oidc var group
# (twin_existing_*_product_id / twin_existing_*_product_key). IDs are lowercased
# (4.6 OIDC audience is case-sensitive); keys are case-preserved (SM compares
# sharedkey case-sensitively at token exchange).

# SMTP - audited 2026-05-13 from xmpro-sm-twin KV. smtp_password via TF_VAR_.
smtp_server               = "sinprd0310.outlook.com"
smtp_username             = "xmprosubscription@xmpro.com"
smtp_from_address         = "xmprosubscription@xmpro.com"
smtp_port                 = 25
smtp_enable_ssl           = true
enable_email_notification = true

# Explicit so the new 4.6 AD can read 4.4-encrypted XMSetting values.
ad_encryption_key = "ay7xokshyiysu"

# XMTwin has a Redis cache but auto_scale_enable was empty in KV.
# To enable: set true + redis_connection_string = "XMTwin-REDIS.redis.cache.windows.net:6380,password=<primary-key>,ssl=True,abortConnect=False"
enable_auto_scale       = false
redis_connection_string = ""

acr_url_product = "xmpro.azurecr.io"
acr_username    = ""
acr_password    = ""

enable_sql_aad_auth = false
db_admin_username   = "xmadmin"
# db_admin_password via TF_VAR_db_admin_password

# Unused in migration mode (use_existing_database=true preserves existing
# XMTwin SM users); placeholders satisfy terraform's required-variable check.
company_admin_password = "placeholder-not-used-in-migration-mode"
site_admin_password    = "placeholder-not-used-in-migration-mode"

imageversion        = "4.6.1"
sm_zip_download_url = "download.app.xmpro.com"
is_evaluation_mode  = false

company_admin_first_name    = "Admin"
company_admin_last_name     = "User"
company_admin_email_address = ""

enable_rbac_authorization = true
enable_ai                 = true
# Disabled: XMTwin's 4.4 schema has no Collection table, so no creds to seed.
# Post-cutover: create a Collection in the 4.6 DS UI and add hosts via stream_hosts.
create_stream_host = false

enable_custom_domain = true
dns_zone_name        = "twin.xmpro.com"

stream_hosts = {
  # MAGS (Central) - if Python is needed in-container, set variant = "bookworm-slim-python3.12"
  magscentral = {
    collection_id     = "a9a6220d-3e6a-449a-b868-509531844693"
    collection_secret = "2F9A80BC-D5B1-4836-B5AA-6E8DA5FCE435"
    variant           = ""
  }
}

prod_networking_enabled = false

keep_or_delete_tag = "keep"
billing_tag        = "production"
