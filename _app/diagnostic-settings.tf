# ============================================================================
# OBSERVABILITY DIAGNOSTIC SETTINGS
# ============================================================================
# Ships App Service and ACI container logs to Event Hub for collection by the
# observability platform (OTel Collector -> Loki -> Grafana).
# Enabled by setting enable_otel = true and providing observability_eventhub_rule_id.

locals {
  observability_eventhub_rule_id = trimspace(var.observability_eventhub_rule_id)
  diag_enabled                   = var.enable_otel && local.observability_eventhub_rule_id != ""
}

check "otel_requires_eventhub_rule_id" {
  assert {
    condition     = !var.enable_otel || local.observability_eventhub_rule_id != ""
    error_message = "observability_eventhub_rule_id must be set when enable_otel is true."
  }
}

# --- App Service diagnostic settings ---
# Log categories: AppServiceConsoleLogs, AppServiceAppLogs, AppServiceHTTPLogs

resource "azurerm_monitor_diagnostic_setting" "ad_app" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ad_app_service.app_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceHTTPLogs" }
}

resource "azurerm_monitor_diagnostic_setting" "ds_app" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ds_app_service.app_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceHTTPLogs" }
}

resource "azurerm_monitor_diagnostic_setting" "sm_app" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.sm_app_service.app_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceHTTPLogs" }
}

resource "azurerm_monitor_diagnostic_setting" "ai_app" {
  count                          = local.diag_enabled && var.enable_ai ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ai_app_service[0].app_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceHTTPLogs" }
}

# --- ACI container diagnostic settings ---
# Log category: ContainerInstanceLog

resource "azurerm_monitor_diagnostic_setting" "stream_host" {
  count                          = local.diag_enabled && var.create_stream_host ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.stream_host_container[0].container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "sc_stream_host" {
  count                          = local.diag_enabled && var.enable_stream_connector_stream_host ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.sc_stream_host_container[0].container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "sm_prep" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.sm_prep_container.container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "sm_dbmigrate" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.sm_dbmigrate.container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "ad_dbmigrate" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ad_dbmigrate.container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "ds_dbmigrate" {
  count                          = local.diag_enabled ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ds_dbmigrate.container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "ai_dbmigrate" {
  count                          = local.diag_enabled && var.enable_ai ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.ai_dbmigrate[0].container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}

resource "azurerm_monitor_diagnostic_setting" "licenses" {
  count                          = local.diag_enabled && var.is_evaluation_mode && !var.use_existing_database ? 1 : 0
  name                           = "diag-obs"
  target_resource_id             = module.licenses_container[0].container_group_id
  eventhub_name                  = var.observability_eventhub_name
  eventhub_authorization_rule_id = local.observability_eventhub_rule_id

  enabled_log { category = "ContainerInstanceLog" }
}
