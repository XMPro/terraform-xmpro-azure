# XMTwin 4.4 -> 4.6 migration - INFRASTRUCTURE LAYER
# Creates a fresh RG (rg-xmtwin-twin01); never touches the existing XMTwin RG.
# The new SQL server is unused at runtime - app layer uses XMTwin's existing
# SQL via use_existing_database=true.

company_name = "xmtwin"
name_suffix  = "twin01"
location     = "centralus" # match XMTwin SQL location for low latency

db_admin_username = "xmadmin"
# db_admin_password via TF_VAR_db_admin_password (needed for new infra SQL,
# unused at runtime since app layer points at XMTwin's existing SQL).

# Match XMTwin prod sizing (P2v2 -> P2v3, same 2-core class).
# SQL S2/100GB mirrors XMTwin even though new SQL is unused at runtime.
ad_service_plan_sku           = "P2v3"
ds_service_plan_sku           = "P2v3"
sm_service_plan_sku           = "P2v3"
ai_service_plan_sku           = "P2v3"
app_service_plan_worker_count = 1
db_sku_name                   = "S2"

storage_account_tier     = "Standard"
storage_replication_type = "LRS"

db_allow_all_ips           = false
create_local_firewall_rule = false

use_existing_database    = true
existing_sql_server_fqdn = "xmtwin-sqlserver-mndr6zvfog2xi.database.windows.net"

# Legacy XMTwin helper-service CNAMEs. Must exist in the new twin.xmpro.com
# zone before the parent NS delegation flip, or these services lose DNS.
additional_dns_cname_records = {
  mlflow = "cg-xmpro-mlflow-twin-centralus.centralus.azurecontainer.io"
  mqtt   = "cg-xmpro-mosqtt-twin-centralus.centralus.azurecontainer.io"
  neo4j  = "cg-xmpro-neo4j-twin-centralus.centralus.azurecontainer.io"
}

# Subdomain delegations from twin.xmpro.com to standalone Azure DNS zones.
# otel.twin.xmpro.com lives in rg-obs-xmpro-twin001 (XMTwin observability stack)
# and needs the parent zone to point at its assigned -02 nameservers.
additional_dns_ns_records = {
  otel = [
    "ns1-02.azure-dns.com.",
    "ns2-02.azure-dns.net.",
    "ns3-02.azure-dns.org.",
    "ns4-02.azure-dns.info.",
  ]
}

enable_app_insights       = true
enable_log_analytics      = true
create_redis_cache        = false
enable_alerting           = false
create_masterdata         = false
enable_ai                 = true
enable_rbac_authorization = true

enable_custom_domain    = true
dns_zone_name           = "twin.xmpro.com"
prod_networking_enabled = false

tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
  Layer       = "Infrastructure"
  Purpose     = "4.4-to-4.6-migration"
  SourceEnv   = "XMTwin"
  Sprinto     = "production"
  Keep        = "keep"
  CreatedOn   = "2026-05-13"
}
