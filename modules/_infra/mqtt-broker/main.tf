# MQTT Broker - Eclipse Mosquitto on Azure Container Apps
# Provides MQTT messaging infrastructure for Stream Connector feature

# Auto-generate credentials if not provided
resource "random_string" "mqtt_user" {
  count   = var.mqtt_user == "" ? 1 : 0
  length  = 12
  upper   = true
  lower   = true
  numeric = true
  special = false

  keepers = {
    company_name = var.company_name
    name_suffix  = var.name_suffix
  }
}

resource "random_password" "mqtt_password" {
  count   = var.mqtt_password == "" ? 1 : 0
  length  = 24
  upper   = true
  lower   = true
  numeric = true
  special = true

  keepers = {
    company_name = var.company_name
    name_suffix  = var.name_suffix
  }
}

locals {
  mqtt_user     = var.mqtt_user != "" ? var.mqtt_user : random_string.mqtt_user[0].result
  mqtt_password = var.mqtt_password != "" ? var.mqtt_password : random_password.mqtt_password[0].result
  mqtt_port     = var.enable_tls ? 8883 : 1883

  # Mosquitto startup script: TLS variant
  mqtt_startup_tls = join(" && ", [
    # Install openssl
    "apk add --no-cache openssl",
    # Decode PFX from Key Vault secret and extract certificate + key
    "echo \"$TLS_PEM_BUNDLE\" | base64 -d > /tmp/cert.pfx",
    "openssl pkcs12 -in /tmp/cert.pfx -clcerts -nokeys -out /mosquitto/data/server.crt -passin pass:",
    "openssl pkcs12 -in /tmp/cert.pfx -nocerts -nodes -out /mosquitto/data/server.key -passin pass:",
    "chmod 644 /mosquitto/data/server.crt",
    "chmod 600 /mosquitto/data/server.key",
    "chown mosquitto:mosquitto /mosquitto/data/server.crt /mosquitto/data/server.key",
    # Write TLS-enabled mosquitto.conf
    "printf 'listener 8883\\ncertfile /mosquitto/data/server.crt\\nkeyfile /mosquitto/data/server.key\\nallow_anonymous false\\npassword_file /mosquitto/data/passwd\\n' > /mosquitto/data/mosquitto.conf",
    # Create password file and start broker
    "printf '%s:%s\\n' \"$MQTT_USER\" \"$MQTT_PASSWORD\" > /mosquitto/data/passwd",
    "mosquitto_passwd -U /mosquitto/data/passwd",
    "exec mosquitto -c /mosquitto/data/mosquitto.conf",
  ])

  # Mosquitto startup script: non-TLS variant
  mqtt_startup_notls = join(" && ", [
    "printf 'listener 1883\\nallow_anonymous false\\npassword_file /mosquitto/data/passwd\\n' > /mosquitto/data/mosquitto.conf",
    "printf '%s:%s\\n' \"$MQTT_USER\" \"$MQTT_PASSWORD\" > /mosquitto/data/passwd",
    "mosquitto_passwd -U /mosquitto/data/passwd",
    "exec mosquitto -c /mosquitto/data/mosquitto.conf",
  ])
}

# ─── TLS Certificate (self-signed via Key Vault) ────────────────────────────

resource "azurerm_key_vault_certificate" "mqtt_tls" {
  count        = var.enable_tls ? 1 : 0
  name         = "mqtt-tls-cert"
  key_vault_id = var.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]

      subject            = "CN=${var.company_name}-mqtt-broker"
      validity_in_months = 60
    }
  }
}

# Read PEM bundle (cert + key) from Key Vault secret
data "azurerm_key_vault_secret" "mqtt_tls_pem" {
  count        = var.enable_tls ? 1 : 0
  name         = azurerm_key_vault_certificate.mqtt_tls[0].name
  key_vault_id = var.key_vault_id
  depends_on   = [azurerm_key_vault_certificate.mqtt_tls]
}

# ─── Container App Environment ──────────────────────────────────────────────

resource "azurerm_container_app_environment" "mqtt" {
  name                       = "cae-mqtt-${var.company_name}-${var.name_suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  infrastructure_subnet_id   = var.infrastructure_subnet_id

  tags = var.tags
}

# ─── MQTT Broker Container App ──────────────────────────────────────────────

resource "azurerm_container_app" "mqtt_broker" {
  name                         = "ca-mqtt-${var.company_name}-${var.name_suffix}"
  container_app_environment_id = azurerm_container_app_environment.mqtt.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "mosquitto"
      image  = "eclipse-mosquitto:2"
      cpu    = var.mqtt_cpu
      memory = var.mqtt_memory

      command = ["/bin/sh", "-c"]
      args    = [var.enable_tls ? local.mqtt_startup_tls : local.mqtt_startup_notls]

      env {
        name  = "MQTT_USER"
        value = local.mqtt_user
      }
      env {
        name        = "MQTT_PASSWORD"
        secret_name = "mqtt-password"
      }

      # TLS PEM bundle env var (only when TLS enabled)
      dynamic "env" {
        for_each = var.enable_tls ? [1] : []
        content {
          name        = "TLS_PEM_BUNDLE"
          secret_name = "tls-pem-bundle"
        }
      }
    }
  }

  secret {
    name  = "mqtt-password"
    value = local.mqtt_password
  }

  # TLS PEM bundle secret (only when TLS enabled)
  dynamic "secret" {
    for_each = var.enable_tls ? [1] : []
    content {
      name  = "tls-pem-bundle"
      value = data.azurerm_key_vault_secret.mqtt_tls_pem[0].value
    }
  }

  ingress {
    external_enabled = var.infrastructure_subnet_id != null
    target_port      = local.mqtt_port
    exposed_port     = local.mqtt_port
    transport        = "tcp"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = merge(var.tags, {
    "Product"    = "MQTT Broker"
    "CreatedFor" = "Stream Connector"
  })
}
