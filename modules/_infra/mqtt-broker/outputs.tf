# MQTT Broker Module Outputs

output "mqtt_broker_fqdn" {
  description = "The FQDN of the MQTT broker Container App"
  value       = azurerm_container_app.mqtt_broker.ingress[0].fqdn
}

output "mqtt_broker_url" {
  description = "The full MQTT connection URL"
  value       = "${var.enable_tls ? "mqtts" : "mqtt"}://${azurerm_container_app.mqtt_broker.ingress[0].fqdn}:${local.mqtt_port}"
}

output "mqtt_broker_port" {
  description = "The MQTT broker port (8883 for TLS, 1883 for non-TLS)"
  value       = local.mqtt_port
}

output "mqtt_broker_tls_enabled" {
  description = "Whether TLS is enabled on the MQTT broker"
  value       = var.enable_tls
}

output "mqtt_user" {
  description = "MQTT broker username"
  value       = local.mqtt_user
  sensitive   = true
}

output "mqtt_password" {
  description = "MQTT broker password"
  value       = local.mqtt_password
  sensitive   = true
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = azurerm_container_app_environment.mqtt.id
}
