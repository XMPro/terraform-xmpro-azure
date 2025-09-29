output "container_group_name" {
  description = "The name of the licenses container group"
  value       = azurerm_container_group.licenses.name
}

output "container_fqdn" {
  description = "The FQDN of the licenses container group"
  value       = azurerm_container_group.licenses.fqdn
}

output "ad_product_id" {
  description = "The AD product ID"
  value       = var.ad_product_id
}

output "ds_product_id" {
  description = "The DS product ID"
  value       = var.ds_product_id
}

output "ai_product_id" {
  description = "The AI product ID"
  value       = var.ai_product_id
}