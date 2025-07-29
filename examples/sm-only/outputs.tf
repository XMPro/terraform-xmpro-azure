# Outputs for Sandbox SM-Only Environment

# Consolidated deployment information for CI/CD verification
output "sm_deployment_info" {
  description = "Essential SM deployment information for CI/CD verification"
  value = {
    # Primary endpoints
    app_url  = module.sm_app_service.app_url
    app_name = module.sm_app_service.app_name

    # Management resources  
    resource_group  = azurerm_resource_group.sm.name
    key_vault_name  = module.sm_key_vault.name
    sql_server_fqdn = module.database.sql_server_fqdn

    # Deployment metadata
    random_suffix = random_id.suffix.hex
    environment   = var.environment
    company_name  = var.companyname
  }
}

# Sensitive deployment package URL (separate for security)
output "sm_zip_package_url" {
  description = "SM deployment package URL (sensitive)"
  value       = module.sm_app_service.zip_package_url
  sensitive   = true
}

