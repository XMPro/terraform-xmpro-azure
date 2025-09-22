resource "random_string" "salt" {
  length  = 13
  special = false
}

# Fixed certificate subject - no random UUID needed

module "sm_key_vault" {
  source = "../key-vault"

  name                = format("kv-sm-%s", substr(var.name_suffix, 0, 16))
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = var.tags

  # Secrets for SM app - merge base secrets with conditional SSO secrets
  secrets = merge({
    "SQLSERVER" = {
      value = format("Data Source=tcp:%s,1433;Initial Catalog=SM;User ID=%s;Password=%s;",
        var.sql_server_fqdn,
        var.db_admin_username,
      var.db_admin_password)
    },
    "ServerUUID" = {
      value = var.sm_product_id
    },
    "DNSName" = {
      value = var.sm_base_url
    },
    "SMTPSERVER" = {
      value = var.smtp_server
    },
    "SMTPFrom" = {
      value = var.smtp_from_address
    },
    "SMTPUSER" = {
      value = var.smtp_username
    },
    "SMTPPASS" = {
      value = var.smtp_password
    },
    "SMTPPORT" = {
      value = var.smtp_port
    },
    "SMTPENABLESSL" = {
      value = var.smtp_enable_ssl
    },
    "SMTPENABLE" = {
      value = var.enable_email_notification
    },
    "AutoScaleEnable" = {
      value = tostring(var.enable_auto_scale)
    },
    "SALT" = {
      value = random_string.salt.result
    },
    "REDIS" = {
      value = var.enable_auto_scale && var.redis_connection_string != "" ? var.redis_connection_string : "-"
    },
    "CERT" = {
      value = "CN=${var.companyname}-SM-SigningCert"
    }
    }, var.sso_enabled ? {
    "SSO-AZURE-AD-CLIENT-ID" = {
      value = var.sso_azure_ad_client_id
    },
    "SSO-AZURE-AD-SECRET" = {
      value = var.sso_azure_ad_secret
    },
    "SSO-BUSINESS-ROLE-CLAIM" = {
      value = var.sso_business_role_claim
    },
    "SSO-AZURE-AD-TENANT-ID" = {
      value = var.sso_azure_ad_tenant_id
    }
  } : {})
}

# Certificate for SM app
resource "azurerm_key_vault_certificate" "cert" {
  name         = "generated-cert"
  key_vault_id = module.sm_key_vault.id
  depends_on   = [module.sm_key_vault]

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
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${var.companyname}-SM-SigningCert"
      validity_in_months = 60
    }
  }

}

# Get the secret value directly using the secret_id from the certificate
data "azurerm_key_vault_secret" "cert_pfx" {
  name         = azurerm_key_vault_certificate.cert.name
  key_vault_id = module.sm_key_vault.id
  depends_on   = [azurerm_key_vault_certificate.cert]
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}
