# URL rewrite layer. Idempotent. Apply after app/ is verified working.

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_subnet" "aci" {
  count                = var.prod_networking_enabled ? 1 : 0
  name                 = var.subnet_names.aci
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

module "url_updater" {
  source = "../../../modules/migrationhelper"

  location            = data.azurerm_resource_group.this.location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  sql_server_fqdn   = var.existing_sql_server_fqdn
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password
  sm_database_name  = var.sm_database_name
  ad_database_name  = var.ad_database_name
  ds_database_name  = var.ds_database_name

  ad_url = var.ad_url
  ds_url = var.ds_url
  ai_url = var.ai_url
  nb_url = var.nb_url

  prod_networking_enabled = var.prod_networking_enabled
  subnet_id               = var.prod_networking_enabled ? data.azurerm_subnet.aci[0].id : null

  tags = merge(var.tags, {
    Layer = "Migration"
  })
}
