# Private Endpoints Module Outputs

output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs"
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_ips" {
  description = "Map of private endpoint names to their private IP addresses"
  value       = { for k, v in azurerm_private_endpoint.this : k => v.private_service_connection[0].private_ip_address }
}
