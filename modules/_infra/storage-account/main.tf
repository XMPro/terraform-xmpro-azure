# Azure Storage Account
resource "azurerm_storage_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  account_kind                  = var.account_kind
  access_tier                   = var.access_tier
  min_tls_version               = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  # Network rules to allow Azure services when public access is disabled
  network_rules {
    default_action             = var.public_network_access_enabled ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Storage file shares
resource "azurerm_storage_share" "shares" {
  for_each = var.file_shares

  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota
}

# Generate SAS token for file share access (valid for 3 years, fixed dates for terraform stability)
data "azurerm_storage_account_sas" "this" {
  connection_string = azurerm_storage_account.this.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = true
  }

  start  = "2025-01-01T00:00:00Z"
  expiry = "2028-01-01T00:00:00Z" # 3 years - fixed dates eliminate terraform regeneration

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

