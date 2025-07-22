# Log analytics workspace for monitoring
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.enable_log_analytics ? 1 : 0
  name                = var.log_analytics_name != "" ? var.log_analytics_name : "log-${var.company_name}-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Application Insights for all applications
resource "azurerm_application_insights" "this" {
  count               = var.enable_app_insights ? 1 : 0
  name                = var.app_insights_name != "" ? var.app_insights_name : "appinsights-${var.company_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  workspace_id        = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].id : null
  tags                = var.tags
}


# Locals for effective resource names and IDs
locals {
  log_analytics_id                 = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].id : null
  log_analytics_primary_shared_key = var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].primary_shared_key : null
  app_insights_id                  = var.enable_app_insights ? azurerm_application_insights.this[0].id : null
  app_insights_connection_string   = var.enable_app_insights ? azurerm_application_insights.this[0].connection_string : null
  app_insights_instrumentation_key = var.enable_app_insights ? azurerm_application_insights.this[0].instrumentation_key : null
}
