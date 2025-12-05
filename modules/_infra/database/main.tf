data "azurerm_client_config" "current" {}

# Azure SQL Server with SQL Authentication
resource "azurerm_mssql_server" "sql_auth" {
  count                        = var.enable_sql_aad_auth ? 0 : 1
  name                         = var.db_server_name != "" ? var.db_server_name : "sql-${var.company_name}-${var.name_suffix}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.db_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.db_minimum_tls_version
  tags                         = var.tags
}

resource "azurerm_mssql_server" "azuread_auth" {
  count                        = var.enable_sql_aad_auth ? 1 : 0
  name                         = var.db_server_name != "" ? var.db_server_name : "sql-${var.company_name}-${var.name_suffix}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.db_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.db_minimum_tls_version
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aad_sql_users_identity_id]
  }

  primary_user_assigned_identity_id = var.aad_sql_users_identity_id

  azuread_administrator {
    login_username              = var.aad_sql_users_identity_name
    object_id                   = var.aad_sql_users_principal_id
    azuread_authentication_only = false
  }
}

# Azure SQL Server Firewall Rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.db_allow_azure_services ? 1 : 0
  name             = "FirewallRule-AllowAzureServices"
  server_id        = local.sql_server_id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allow_all_ips" {
  count            = var.db_allow_all_ips ? 1 : 0
  name             = "FirewallRule-AllowAllIPs"
  server_id        = local.sql_server_id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Azure SQL Server Firewall Rules for additional IP addresses
resource "azurerm_mssql_firewall_rule" "additional_rules" {
  for_each         = var.db_firewall_rules
  name             = each.key
  server_id        = local.sql_server_id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Azure SQL Server Virtual Network Rules
resource "azurerm_mssql_virtual_network_rule" "vnet_rules" {
  for_each  = var.db_vnet_rules
  name      = each.key
  server_id = local.sql_server_id
  subnet_id = each.value.subnet_id
}

# Azure SQL Databases
resource "azurerm_mssql_database" "databases" {
  for_each       = var.databases
  name           = each.key
  server_id      = local.sql_server_id
  collation      = each.value.collation
  max_size_gb    = each.value.max_size_gb
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant
  create_mode    = each.value.create_mode
  tags           = var.tags
}

# Locals for SQL server properties
locals {
  sql_server_id   = var.enable_sql_aad_auth ? azurerm_mssql_server.azuread_auth[0].id : azurerm_mssql_server.sql_auth[0].id
  sql_server_name = var.enable_sql_aad_auth ? azurerm_mssql_server.azuread_auth[0].name : azurerm_mssql_server.sql_auth[0].name
  sql_server_fqdn = var.enable_sql_aad_auth ? azurerm_mssql_server.azuread_auth[0].fully_qualified_domain_name : azurerm_mssql_server.sql_auth[0].fully_qualified_domain_name
}