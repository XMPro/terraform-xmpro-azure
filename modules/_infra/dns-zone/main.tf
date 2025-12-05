# Azure DNS Zone for custom domains
resource "azurerm_dns_zone" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Local for the effective DNS zone name
locals {
  effective_name = var.name
}

# DNS TXT records for domain verification
resource "azurerm_dns_txt_record" "domain_verification" {
  for_each            = var.domain_verification_records
  name                = "asuid.${each.key}"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = var.record_ttl

  record {
    value = each.value.verification_id
  }
}

# DNS CNAME records
resource "azurerm_dns_cname_record" "cname_records" {
  for_each            = var.cname_records
  name                = each.key
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = var.record_ttl
  record              = each.value.record

  depends_on = [azurerm_dns_txt_record.domain_verification]
}

# App Service custom hostname bindings
resource "azurerm_app_service_custom_hostname_binding" "hostname_bindings" {
  for_each            = var.hostname_bindings
  hostname            = "${each.key}.${azurerm_dns_zone.this.name}"
  app_service_name    = each.value.app_service_name
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_dns_cname_record.cname_records]
}

# App Service managed certificates
resource "azurerm_app_service_managed_certificate" "certificates" {
  for_each                   = var.hostname_bindings
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_bindings[each.key].id
}

# App Service certificate bindings
resource "azurerm_app_service_certificate_binding" "certificate_bindings" {
  for_each            = var.hostname_bindings
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.hostname_bindings[each.key].id
  certificate_id      = azurerm_app_service_managed_certificate.certificates[each.key].id
  ssl_state           = "SniEnabled"
}
