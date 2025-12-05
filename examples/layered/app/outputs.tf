# Output validation warnings and information

output "sas_token_validation" {
  description = "SAS token validation status - warns if provided token doesn't match current storage account token"
  value       = local.sas_tokens_match ? "✓ SAS token is current and valid" : "⚠️  WARNING: Provided SAS token does not match current storage account token. Update storage_sas_token in terraform.tfvars with the current token from infrastructure layer output."
  sensitive   = true
}

output "current_sas_token_hint" {
  description = "Hint for getting current SAS token from infrastructure layer"
  value       = "Run: cd ../infra && terraform output -raw storage_account_sas_token"
  sensitive   = false
}

# Pass through application URLs from _app module
output "sm_app_url" {
  description = "Subscription Manager application URL"
  value       = module.applications.sm_app_url
}

output "ad_app_url" {
  description = "App Designer application URL"
  value       = module.applications.ad_app_url
}

output "ds_app_url" {
  description = "Data Stream Designer application URL"
  value       = module.applications.ds_app_url
}

# Additional Stream Hosts
output "stream_hosts" {
  description = "Information about deployed stream hosts"
  sensitive   = true
  value = {
    for name, config in var.stream_hosts : name => {
      container_group_id   = module.stream_host[name].container_group_id
      container_group_name = module.stream_host[name].container_group_name
      ds_server_url        = var.stream_host_ds_server_url != "" ? var.stream_host_ds_server_url : module.applications.ds_app_url
      collection_id        = config.collection_id
      variant              = config.variant != "" ? config.variant : "bookworm-slim (default)"
      cpu_cores            = config.cpu
      memory_gb            = config.memory
      alerting_enabled     = var.stream_host_enable_alerting
    }
  }
}

output "stream_hosts_summary" {
  description = "Summary of deployed stream hosts"
  value       = "Deployed ${length(var.stream_hosts)} additional stream host(s): ${join(", ", keys(var.stream_hosts))}"
}
