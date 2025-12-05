output "private_endpoint_id" {
  description = "Private endpoint ID"
  value       = azurerm_private_endpoint.app_service.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the endpoint"
  value       = length(azurerm_private_endpoint.app_service.private_service_connection) > 0 ? azurerm_private_endpoint.app_service.private_service_connection[0].private_ip_address : ""
}

output "private_endpoint_fqdn" {
  description = "FQDN of the private endpoint"
  value       = length(azurerm_private_endpoint.app_service.custom_dns_configs) > 0 ? azurerm_private_endpoint.app_service.custom_dns_configs[0].fqdn : ""
}
