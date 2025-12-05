output "id" {
  description = "The ID of the SM key vault"
  value       = data.azurerm_key_vault.sm_key_vault.id
}

output "name" {
  description = "The name of the SM key vault"
  value       = data.azurerm_key_vault.sm_key_vault.name
}

output "certificate_id" {
  description = "The ID of the generated certificate"
  value       = azurerm_key_vault_certificate.cert.id
}

output "certificate_name" {
  description = "The name of the generated certificate"
  value       = azurerm_key_vault_certificate.cert.name
}

output "certificate_subject" {
  description = "The subject of the generated certificate"
  value       = "CN=${var.companyname}-SM-SigningCert"
}

output "certificate_secret_id" {
  description = "The versionless secret ID of the generated certificate for app service"
  value       = azurerm_key_vault_certificate.cert.versionless_secret_id
}

output "certificate_pfx_blob" {
  description = "The PFX blob containing both certificate and private key from secret value"
  value       = data.azurerm_key_vault_secret.cert_pfx.value
  sensitive   = true
}



output "random_salt" {
  description = "The random salt string generated for SM app"
  value       = random_string.salt.result
  sensitive   = true
}

output "name_suffix" {
  description = "The random name suffix used for resources"
  value       = var.name_suffix
}
