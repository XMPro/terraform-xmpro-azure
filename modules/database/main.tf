# Azure SQL Server
resource "azurerm_mssql_server" "this" {
  name                         = var.db_server_name != "" ? var.db_server_name : "sql-${var.company_name}-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.db_server_version
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = var.db_minimum_tls_version
  tags                         = var.tags
}

# Azure SQL Server Firewall Rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.db_allow_azure_services ? 1 : 0
  name             = "FirewallRule-AllowAzureServices"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allow_all_ips" {
  count            = var.db_allow_all_ips ? 1 : 0
  name             = "FirewallRule-AllowAllIPs"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

# Azure SQL Server Firewall Rules for additional IP addresses
resource "azurerm_mssql_firewall_rule" "additional_rules" {
  for_each         = var.db_firewall_rules
  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Azure SQL Databases
resource "azurerm_mssql_database" "databases" {
  for_each       = var.databases
  name           = each.key
  server_id      = azurerm_mssql_server.this.id
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
  sql_server_id   = azurerm_mssql_server.this.id
  sql_server_name = azurerm_mssql_server.this.name
  sql_server_fqdn = azurerm_mssql_server.this.fully_qualified_domain_name
}

# External data source to fetch public IP using the script
# Only execute when creating local firewall rule
data "external" "get_public_ip" {
  count   = var.create_local_firewall_rule ? 1 : 0
  program = substr(pathexpand("~"), 0, 1) == "/" ? ["bash", "${path.module}/get_public_ip.sh"] : ["powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", "${path.module}/get_public_ip.ps1"]
}

# Firewall rule using the fetched IP
resource "azurerm_mssql_firewall_rule" "allow_local_access" {
  count            = var.create_local_firewall_rule ? 1 : 0
  name             = "allow-local-access"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = data.external.get_public_ip[0].result["public_ip"]
  end_ip_address   = data.external.get_public_ip[0].result["public_ip"]
}
