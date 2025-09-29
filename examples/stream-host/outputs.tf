# Outputs for Stream Host deployment

output "resource_group_name" {
  description = "The name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].id : module.resource_group[0].id
}

output "stream_host_container_group_id" {
  description = "The ID of the stream host container group"
  value       = module.stream_host.container_group_id
}

output "stream_host_container_group_name" {
  description = "The name of the stream host container group"
  value       = module.stream_host.container_group_name
}