output "id" {
  description = "The ID of the DNS Zone"
  value       = azurerm_dns_zone.this.id
}

output "name" {
  description = "The name of the DNS Zone"
  value       = azurerm_dns_zone.this.name
}

output "name_servers" {
  description = "The nameservers of the DNS Zone"
  value       = azurerm_dns_zone.this.name_servers
}

output "effective_name" {
  description = "The effective name of the DNS Zone (with random suffix if enabled)"
  value       = local.effective_name
}

output "txt_record_ids" {
  description = "Map of TXT record IDs"
  value       = { for k, v in azurerm_dns_txt_record.domain_verification : k => v.id }
}

output "cname_record_ids" {
  description = "Map of CNAME record IDs"
  value       = { for k, v in azurerm_dns_cname_record.cname_records : k => v.id }
}

output "hostname_binding_ids" {
  description = "Map of hostname binding IDs"
  value       = { for k, v in azurerm_app_service_custom_hostname_binding.hostname_bindings : k => v.id }
}

output "certificate_ids" {
  description = "Map of certificate IDs"
  value       = { for k, v in azurerm_app_service_managed_certificate.certificates : k => v.id }
}
