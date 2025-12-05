resource "azurerm_user_assigned_identity" "aad_sql_users" {
  name                = "mi-${var.company_name}-aadsqlusers-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "sm_app" {
  name                = "mi-${var.company_name}-sm-db-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "ad_app" {
  name                = "mi-${var.company_name}-ad-db-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "ds_app" {
  name                = "mi-${var.company_name}-ds-db-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "ai_app" {
  count               = var.enable_ai ? 1 : 0
  name                = "mi-${var.company_name}-ai-db-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
