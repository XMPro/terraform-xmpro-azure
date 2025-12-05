output "sql_server_id" {
  description = "The ID of the SQL server"
  value       = local.sql_server_id
}

output "sql_server_name" {
  description = "The name of the SQL server"
  value       = local.sql_server_name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = local.sql_server_fqdn
}

output "sql_server_connection_string" {
  description = "The connection string for the SQL server (uses managed identity when Azure AD/AAD auth is enabled)"
  value = var.enable_sql_aad_auth ? (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=master;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    ) : (
    "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=master;Persist Security Info=False;User ID=${var.administrator_login};Password=${var.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  )
  sensitive = true
}

output "database_ids" {
  description = "Map of database names to their IDs"
  value       = { for k, v in azurerm_mssql_database.databases : k => v.id }
}

output "database_connection_strings" {
  description = "Map of database names to their connection strings (uses managed identity when Azure AD/AAD auth is enabled)"
  value = var.enable_sql_aad_auth ? {
    for k, v in azurerm_mssql_database.databases : k => "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${k};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    } : {
    for k, v in azurerm_mssql_database.databases : k => "Server=tcp:${local.sql_server_fqdn},1433;Initial Catalog=${k};Persist Security Info=False;User ID=${var.administrator_login};Password=${var.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
  sensitive = true
}
