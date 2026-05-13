output "migration_container_name" {
  description = "Name of the migration helper ACI. View logs with: az container logs --resource-group <rg> --name <this>"
  value       = module.url_updater.container_group_name
}

output "logs_command" {
  description = "Command to view the migration helper container's logs"
  value       = "az container logs --resource-group ${var.resource_group_name} --name ${module.url_updater.container_group_name}"
}
