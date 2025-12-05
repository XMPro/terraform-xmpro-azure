# Application DNS Configuration Outputs

output "dns_zone_name" {
  description = "Name of the DNS zone"
  value       = data.azurerm_dns_zone.this.name
}

output "dns_zone_name_servers" {
  description = "Name servers of the DNS zone"
  value       = data.azurerm_dns_zone.this.name_servers
}

output "hostname_bindings" {
  description = "Map of hostname bindings created"
  value = {
    for k, v in azurerm_app_service_custom_hostname_binding.hostname_bindings : k => {
      hostname = v.hostname
      id       = v.id
    }
  }
}

output "certificates" {
  description = "Map of managed certificates created"
  value = {
    for k, v in azurerm_app_service_managed_certificate.certificates : k => {
      id              = v.id
      thumbprint      = v.thumbprint
      issue_date      = v.issue_date
      expiration_date = v.expiration_date
    }
  }
}