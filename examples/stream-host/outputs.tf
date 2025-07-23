# Outputs for Stream Host deployment

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = module.resource_group.id
}

output "stream_host_container_group_id" {
  description = "The ID of the stream host container group"
  value       = module.stream_host.container_group_id
}

output "stream_host_container_group_name" {
  description = "The name of the stream host container group"
  value       = module.stream_host.container_group_name
}