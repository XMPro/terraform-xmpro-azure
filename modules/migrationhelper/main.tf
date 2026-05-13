# One-shot ACI that rewrites Product URLs / ServerVariables in existing 4.4
# SM/AD/DS DBs to point at new 4.6 App Service URLs. SQL mounted as a secret
# volume on stock mssql-tools.

locals {
  container_group_name = substr(lower("ci-${var.company_name}-migrationhelper-${var.name_suffix}"), 0, 63)
  scripts = {
    "run.sh"        = filebase64("${path.module}/scripts/run.sh")
    "phase2_sm.sql" = filebase64("${path.module}/scripts/phase2_sm.sql")
    "phase2_ad.sql" = filebase64("${path.module}/scripts/phase2_ad.sql")
    "phase2_ds.sql" = filebase64("${path.module}/scripts/phase2_ds.sql")
  }
}

resource "azurerm_container_group" "migration" {
  name                = local.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = var.prod_networking_enabled ? "Private" : "Public"
  os_type             = "Linux"
  restart_policy      = "Never"
  subnet_ids          = var.prod_networking_enabled ? [var.subnet_id] : null

  container {
    name     = "migrationhelper"
    image    = "mcr.microsoft.com/mssql-tools:latest"
    cpu      = 0.5
    memory   = 1.0
    commands = ["sh", "/scripts/run.sh"]

    environment_variables = {
      "SQLCMDSERVER" = var.sql_server_fqdn

      # Database users (one admin used for all three)
      "SMDB_USER" = var.db_admin_username
      "ADDB_USER" = var.db_admin_username
      "DSDB_USER" = var.db_admin_username

      # Database names (default SM/AD/DS)
      "SMDB_NAME" = var.sm_database_name
      "ADDB_NAME" = var.ad_database_name
      "DSDB_NAME" = var.ds_database_name

      # Target URLs written into the existing 4.4 databases
      "AD_BASEURL_CLIENT"             = var.ad_url
      "DS_BASEURL_CLIENT"             = var.ds_url
      "AI_BASEURL_CLIENT"             = var.ai_url
      "XMPRO_NOTEBOOK_BASEURL_CLIENT" = var.nb_url
    }

    secure_environment_variables = {
      "SMDB_PASSWORD" = var.db_admin_password
      "ADDB_PASSWORD" = var.db_admin_password
      "DSDB_PASSWORD" = var.db_admin_password
    }

    volume {
      name       = "scripts"
      mount_path = "/scripts"
      read_only  = true
      secret     = local.scripts
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = merge(var.tags, {
    "Purpose" = "migrationhelper"
  })
}
