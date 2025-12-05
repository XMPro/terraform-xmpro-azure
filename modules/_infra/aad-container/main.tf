resource "azurerm_container_group" "aad_sql_users" {
  name                = "ci-${var.company_name}-aadsqlusers-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  restart_policy      = "Never"
  ip_address_type     = "None"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aad_sql_users_identity_id]
  }

  container {
    name   = "sql-user-creator"
    image  = "debian:bullseye"
    cpu    = "0.5"
    memory = "1"

    environment_variables = {
      SQL_SERVER = var.sql_server_fqdn
      CLIENT_ID  = var.aad_sql_users_client_id
      SM_USER    = var.sm_app_identity_name
      AD_USER    = var.ad_app_identity_name
      DS_USER    = var.ds_app_identity_name
      AI_USER    = var.ai_app_identity_name
      DATABASES_CONFIG = jsonencode([
        for db_name in keys(var.databases) : [
          db_name,
          (length(regexall("subscriptionmanager", lower(db_name))) > 0 || lower(db_name) == "sm") ? var.sm_app_identity_name :
          (length(regexall("appdesigner", lower(db_name))) > 0 || lower(db_name) == "ad") ? var.ad_app_identity_name :
          (length(regexall("datastream", lower(db_name))) > 0 || lower(db_name) == "ds") ? var.ds_app_identity_name :
          (length(regexall("ai", lower(db_name))) > 0) ? var.ai_app_identity_name :
          ""
        ]
      ])
    }

    commands = [
      "/bin/bash", "-c",
      <<-EOT
        set -e
        apt-get update -qq
        apt-get install -y -qq python3 python3-pip curl gnupg
        curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
        curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
        apt-get update -qq
        ACCEPT_EULA=Y apt-get install -y -qq msodbcsql17
        pip3 install pyodbc azure-identity
        cat > /tmp/grant_permissions.py <<'PYTHON'
${file("${path.module}/grant_aad_permissions.py")}
PYTHON
        python3 /tmp/grant_permissions.py
        sleep 30
      EOT
    ]
  }

  tags = var.tags
}
