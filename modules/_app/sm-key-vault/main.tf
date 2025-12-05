resource "random_string" "salt" {
  length  = 13
  special = false
}

# Fixed certificate subject - no random UUID needed

# Reference existing Key Vault from infrastructure layer
data "azurerm_key_vault" "sm_key_vault" {
  name                = var.sm_key_vault_name
  resource_group_name = var.resource_group_name
}

# Manage secrets in the existing Key Vault
module "sm_secrets" {
  source = "../keyvault-secrets"

  key_vault_name      = var.sm_key_vault_name
  resource_group_name = var.resource_group_name

  secrets = merge({
    # SM always uses SQL authentication (not AAD) because SM uses .NET Framework
    # which doesn't support AAD managed identity authentication (see Work Item #21949)
    "SQLSERVER" = format("Data Source=tcp:%s,1433;Initial Catalog=%s;User ID=%s;Password=%s;",
      var.sql_server_fqdn,
      var.sm_database_name,
      var.db_admin_username,
      var.db_admin_password
    )
    "ServerUUID"      = var.sm_product_id
    "DNSName"         = var.sm_base_url
    "SMTPSERVER"      = var.smtp_server
    "SMTPFrom"        = var.smtp_from_address
    "SMTPUSER"        = var.smtp_username
    "SMTPPASS"        = var.smtp_password
    "SMTPPORT"        = tostring(var.smtp_port)
    "SMTPENABLESSL"   = tostring(var.smtp_enable_ssl)
    "SMTPENABLE"      = tostring(var.enable_email_notification)
    "AutoScaleEnable" = tostring(var.enable_auto_scale)
    "SALT"            = random_string.salt.result
    "REDIS"           = var.enable_auto_scale && var.redis_connection_string != "" ? var.redis_connection_string : "-"
    "CERT"            = "CN=${var.companyname}-SM-SigningCert"
    }, var.sso_enabled ? {
    "SSO-AZURE-AD-CLIENT-ID"  = var.sso_azure_ad_client_id
    "SSO-AZURE-AD-SECRET"     = var.sso_azure_ad_secret
    "SSO-BUSINESS-ROLE-CLAIM" = var.sso_business_role_claim
    "SSO-AZURE-AD-TENANT-ID"  = var.sso_azure_ad_tenant_id
  } : {})

  tags = var.tags
}

# Certificate for SM app
resource "azurerm_key_vault_certificate" "cert" {
  name         = "generated-cert"
  key_vault_id = data.azurerm_key_vault.sm_key_vault.id

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
  key_vault_id = data.azurerm_key_vault.sm_key_vault.id
  depends_on   = [azurerm_key_vault_certificate.cert]
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}
