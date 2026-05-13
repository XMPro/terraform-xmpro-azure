# MQTT Broker for Stream Connector (conditional - only deploy if not using existing)
module "mqtt_broker" {
  count  = var.enable_stream_connector && !var.use_existing_mqtt_broker ? 1 : 0
  source = "../modules/_infra/mqtt-broker"

  company_name        = var.company_name
  name_suffix         = var.name_suffix
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  # Log Analytics workspace for Container App Environment
  log_analytics_workspace_resource_id = module.monitoring.log_analytics_workspace_resource_id

  # VNet integration (required for external TCP ingress)
  infrastructure_subnet_id = var.prod_networking_enabled ? module.subnets[0].subnet_ids["containerapp"] : null

  # TLS certificate (uses dedicated MQTT Key Vault for cert storage)
  enable_tls   = var.mqtt_enable_tls
  key_vault_id = var.mqtt_enable_tls ? module.key_vault_mqtt[0].id : ""

  # MQTT credentials (auto-generated if empty)
  mqtt_user     = var.mqtt_user
  mqtt_password = var.mqtt_password
  mqtt_cpu      = var.mqtt_cpu
  mqtt_memory   = var.mqtt_memory

  tags = local.common_tags

  # Ensure Key Vault RBAC role assignment has propagated before creating certificates
  depends_on = [module.key_vault_mqtt]
}
