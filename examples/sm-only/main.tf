# Sandbox SM-Only Environment
# Complete SM deployment with containerized zip preparation and App Service deployment

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate unique suffix for resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Resource Group for SM deployment
resource "azurerm_resource_group" "sm" {
  name     = "rg-${var.companyname}-${var.environment}-sm-${random_id.suffix.hex}"
  location = var.location
}

# Storage Account Module
module "storage_account" {
  source = "../../modules/storage-account"

  name_prefix         = "stsm${random_id.suffix.hex}"
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  file_shares = {
    "sm-zip-prep-share" = {
      quota = 5
    }
  }
  tags = {
    Environment = var.environment
    Purpose     = "sm-testing"
  }
}

# Database Module for SM testing
module "database" {
  source = "../../modules/database"

  # Basic configuration
  company_name        = var.companyname
  environment         = var.environment
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name

  # SQL Server configuration with consistent suffix naming
  db_server_name               = "sqldb-${var.companyname}-${var.environment}-${random_id.suffix.hex}"
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  db_allow_azure_services      = true
  db_allow_all_ips             = true # For testing only

  # Create SM database with minimal configuration (matches dev environment)
  databases = {
    "SM" = {
      collation      = "SQL_Latin1_General_CP1_CI_AS"
      max_size_gb    = 2
      read_scale     = false
      sku_name       = "Basic"
      zone_redundant = false
      create_mode    = "Default"
    }
  }

  tags = {
    Environment = var.environment
    Purpose     = "sm-database-testing"
    CreatedBy   = "terraform"
    Company     = var.companyname
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Generate a random UUID for SM product ID (matches dev environment pattern)
resource "random_uuid" "sm_product_id" {}

# Local values for reuse
locals {
  sm_product_id = random_uuid.sm_product_id.result
}

# SM Key Vault Module (moved to top level for proper module composition)
module "sm_key_vault" {
  source = "../../modules/sm-key-vault"

  # Pass through variables
  environment         = var.environment
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  companyname         = var.companyname
  name_suffix         = "${var.companyname}-${random_id.suffix.hex}"
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  sm_product_id       = local.sm_product_id
  sql_server_fqdn     = module.database.sql_server_fqdn

  # SMTP Configuration (disabled for sandbox)
  enable_email_notification = false
  smtp_server               = ""
  smtp_from_address         = ""
  smtp_username             = ""
  smtp_password             = ""
  smtp_port                 = 587
  smtp_enable_ssl           = true

  # SM Base URL for configuration
  sm_base_url = "https://app-sm-${var.environment}-${var.companyname}-${random_id.suffix.hex}.azurewebsites.net"

  # Tags
  tags = {
    Environment = var.environment
    Purpose     = "sm-sandbox-deployment"
    CreatedBy   = "terraform"
    Company     = var.companyname
  }

  depends_on = [module.database]
}

# SM Preparation Container Module (creates SM.zip first)
module "sm_prep_container" {
  source = "../../modules/sm-prep-container"

  # Basic configuration
  environment         = var.environment
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  company_name        = var.companyname

  # Storage configuration
  storage_account_name = module.storage_account.name
  storage_account_key  = module.storage_account.primary_access_key
  storage_share_id     = module.storage_account.file_shares["sm-zip-prep-share"]
  share_name           = "sm-zip-prep-share" # Explicit file share name

  # Release version
  release_version = var.github_release_version

  # Key Vault configuration (calculated name - no dependency needed)
  keyvault_name = "kvsm${substr("${var.companyname}${random_id.suffix.hex}", 0, 19)}"

  # Implicit dependencies through variable references handle storage account dependency
}

# SM Database Migration Module (initializes database schema and users)
module "sm_dbmigrate" {
  source = "../../modules/sm-dbmigrate"

  # Basic configuration
  environment         = var.environment
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  company_name        = var.companyname
  deployment_suffix   = random_id.suffix.hex

  # Database configuration (use actual database, matches dev environment)
  db_connection_string = module.database.database_connection_strings["SM"]
  sm_database_id       = module.database.database_ids["SM"]

  # Company Admin configuration
  company_admin_email_address = "admin@${var.companyname}.com"
  company_admin_username      = "admin.user@${var.companyname}.onxmpro.com"
  
  # SM Configuration
  sm_product_id = local.sm_product_id

  # Container Registry configuration
  acr_url_product     = "xmprononprod.azurecr.io"
  is_private_registry = false
  imageversion        = "latest"

  # Admin passwords
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Application URLs (sandbox placeholders)
  ad_url = "https://ad-${var.environment}.azurewebsites.net"
  ds_url = "https://ds-${var.environment}.azurewebsites.net"
  ai_url = "https://ai-${var.environment}.azurewebsites.net"
  nb_url = "https://nb-${var.environment}.azurewebsites.net"

  tags = {
    Environment = var.environment
    Purpose     = "sm-database-migration"
    CreatedBy   = "terraform"
    Company     = var.companyname
  }

}

# SM App Service Module (uses Key Vault from top level)
module "sm_app_service" {
  source = "../../modules/sm-app-service"

  # Basic configuration
  tenant_id           = data.azurerm_client_config.current.tenant_id
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  companyname         = var.companyname
  name_suffix         = "${var.companyname}-${random_id.suffix.hex}"

  # Key Vault configuration (use Key Vault from top level)
  key_vault_id = module.sm_key_vault.id

  # Certificate configuration (pass PFX blob directly to eliminate data source dependency)
  certificate_pfx_blob = module.sm_key_vault.certificate_pfx_blob

  # Database configuration (use actual database, matches dev environment)
  db_admin_username    = var.db_admin_username
  db_admin_password    = var.db_admin_password
  db_connection_string = module.database.database_connection_strings["SM"]
  sql_server_fqdn      = module.database.sql_server_fqdn

  # SM Configuration
  sm_product_id = local.sm_product_id
  sm_url        = "https://app-sm-${var.environment}-${var.companyname}-${random_id.suffix.hex}.azurewebsites.net"

  # App Service configuration
  service_plan_sku = "B1" # Basic tier for sandbox

  # Storage configuration for deployment
  files_location       = "sm-zip-prep-share" # Explicit file share name
  storage_account_name = module.storage_account.name
  storage_sas_token    = module.storage_account.sas_token

  # GitHub release version for versioned zip file
  github_release_version = var.github_release_version

  # Application passwords
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Other application URLs (sandbox placeholders)
  ad_url = "https://ad-${var.environment}.azurewebsites.net"
  ds_url = "https://ds-${var.environment}.azurewebsites.net"

  tags = {
    Environment = var.environment
    Purpose     = "sm-sandbox-deployment"
    CreatedBy   = "terraform"
    Company     = var.companyname
  }

  # Create implicit dependency on sm-prep-container
  sm_prep_container_id = module.sm_prep_container.container_group_id

  # Explicit dependency: Ensure app service waits for prep container and Key Vault (includes certificate)
  depends_on = [module.sm_prep_container, module.sm_key_vault]
}



