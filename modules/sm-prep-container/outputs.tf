# SM Zip Preparation Module Outputs

output "container_group_id" {
  description = "The ID of the container group"
  value       = azurerm_container_group.sm_zip_prep.id
}

output "container_group_name" {
  description = "The name of the container group"
  value       = azurerm_container_group.sm_zip_prep.name
}

output "container_group_fqdn" {
  description = "The FQDN of the container group"
  value       = azurerm_container_group.sm_zip_prep.fqdn
}

output "container_group_ip_address" {
  description = "The IP address allocated to the container group"
  value       = azurerm_container_group.sm_zip_prep.ip_address
}

# Output information for monitoring and debugging
output "container_deployment_trigger" {
  description = "The deployment trigger timestamp used for this container"
  value       = "terraform-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

output "storage_files_uploaded" {
  description = "List of files uploaded to storage share"
  value = [
    azurerm_storage_share_file.prepare_script.name
  ]
}

# Script change detection outputs
output "scripts_hash_info" {
  description = "Hash information for script change detection"
  value = {
    prepare_script_hash   = local.prepare_script_hash
    combined_scripts_hash = local.scripts_combined_hash
  }
}

# SM.zip download URL configuration
output "sm_zip_download_url" {
  description = "The configured SM.zip download URL (empty means use default load balancer URL)"
  value       = var.sm_zip_download_url != "" ? var.sm_zip_download_url : "https://download.nonprod.xmprodev.com/SM/SM-${var.release_version}.zip"
}