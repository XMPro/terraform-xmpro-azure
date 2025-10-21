# Infrastructure Layer - Core Azure Resources
# This module contains infrastructure resources like resource groups, storage accounts,
# databases, key vaults, monitoring, and networking components

# Resource Group (core infrastructure)
module "resource_group" {
  source = "../modules/_infra/resource-group"

  name     = "rg-${var.company_name}-${var.name_suffix}"
  location = var.location
  tags = merge(local.common_tags, {
    "CreatedFor" = "${var.company_name}-${var.name_suffix} Terraform Infrastructure module"
  })
}

# DNS Zone (networking infrastructure)
module "dns_zone" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../modules/_infra/dns-zone"

  name                = var.dns_zone_name
  resource_group_name = module.resource_group.name
  tags                = local.common_tags
}

# Storage Account Module for deployment assets
module "storage_account" {
  source = "../modules/_infra/storage-account"

  name                = "st${substr(var.company_name, 0, 3)}${var.name_suffix}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = true # Keep enabled for Terraform access even with private endpoints

  file_shares = {
    "sm-zip-prep-share" = {
      quota = 5
    }
  }
  tags = merge(local.common_tags, {
    "Purpose" = "deployment-assets"
  })
}

# Primary Database (only when not using existing database)
module "database" {
  count  = var.use_existing_database ? 0 : 1
  source = "../modules/_infra/database"

  company_name                 = var.company_name
  name_suffix                  = var.name_suffix
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  db_server_name               = "sql-${var.company_name}-${var.name_suffix}"

  databases = merge({
    (var.ad_database_name) = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    },
    (var.ds_database_name) = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    },
    (var.sm_database_name) = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    }
    }, var.enable_ai ? {
    (var.ai_database_name) = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    }
  } : {})

  db_allow_azure_services    = true
  db_allow_all_ips           = var.db_allow_all_ips
  create_local_firewall_rule = var.create_local_firewall_rule

  # VNet rules for presentation subnet (App Services access via service endpoint)
  db_vnet_rules = var.prod_networking_enabled ? {
    allow-presentation-subnet = {
      subnet_id = module.subnets[0].subnet_ids["presentation"]
    }
  } : {}

  tags = local.common_tags
}

# Master Data Database Server (separate server infrastructure)
module "masterdata_database" {
  count  = var.create_masterdata ? 1 : 0
  source = "../modules/_infra/database"

  company_name                 = var.company_name
  name_suffix                  = var.name_suffix
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  administrator_login          = var.masterdata_db_admin_username
  administrator_login_password = var.masterdata_db_admin_password
  db_server_name               = "sqldb-masterdata-${var.company_name}-${var.name_suffix}"

  databases = {
    "MasterData" = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    }
  }

  db_allow_azure_services    = true
  db_allow_all_ips           = var.db_allow_all_ips
  create_local_firewall_rule = var.create_local_firewall_rule

  # VNet rules for presentation subnet (App Services access via service endpoint)
  db_vnet_rules = var.prod_networking_enabled ? {
    allow-presentation-subnet = {
      subnet_id = module.subnets[0].subnet_ids["presentation"]
    }
  } : {}

  tags = local.common_tags
}

# Redis Cache Infrastructure (conditional)
module "redis_cache" {
  count  = var.create_redis_cache ? 1 : 0
  source = "../modules/_infra/redis-cache"

  # Basic configuration
  company_name        = var.company_name
  name_suffix         = var.name_suffix
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  # Tags
  tags = local.common_tags
}

# Key Vaults for each application
data "azurerm_client_config" "current" {}

module "key_vault_ad" {
  source = "../modules/_infra/key-vault"

  name                     = substr("kv-ad-${var.company_name}-${var.name_suffix}", 0, 24)
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  object_id                = data.azurerm_client_config.current.object_id
  keyvault_admin_role_name = var.keyvault_admin_role_name
  tags                     = local.common_tags
}

module "key_vault_ds" {
  source = "../modules/_infra/key-vault"

  name                     = substr("kv-ds-${var.company_name}-${var.name_suffix}", 0, 24)
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  object_id                = data.azurerm_client_config.current.object_id
  keyvault_admin_role_name = var.keyvault_admin_role_name
  tags                     = local.common_tags
}

module "key_vault_sm" {
  source = "../modules/_infra/key-vault"

  name                     = substr("kv-sm-${var.company_name}-${var.name_suffix}", 0, 24)
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  object_id                = data.azurerm_client_config.current.object_id
  keyvault_admin_role_name = var.keyvault_admin_role_name
  tags                     = local.common_tags
}

module "key_vault_ai" {
  count  = var.enable_ai ? 1 : 0
  source = "../modules/_infra/key-vault"

  name                     = substr("kv-ai-${var.company_name}-${var.name_suffix}", 0, 24)
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  object_id                = data.azurerm_client_config.current.object_id
  keyvault_admin_role_name = var.keyvault_admin_role_name
  tags                     = local.common_tags
}

# Monitoring Infrastructure
module "monitoring" {
  source = "../modules/_infra/monitoring"

  company_name        = var.company_name
  name_suffix         = var.name_suffix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags

  # Optional parameters
  enable_log_analytics = true
  enable_app_insights  = true
  app_insights_name    = "appinsights-${var.company_name}-${var.name_suffix}"
  log_analytics_name   = "log-${var.company_name}-${var.name_suffix}"
}

# App Service Plans (infrastructure for hosting applications)
module "app_service_plan_ad" {
  source = "../modules/_infra/app-service-plan"

  name                = "plan-ad-${var.company_name}-${var.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Linux"
  sku_name            = var.ad_service_plan_sku
  worker_count        = var.app_service_plan_worker_count
  tags                = local.common_tags
}

module "app_service_plan_ds" {
  source = "../modules/_infra/app-service-plan"

  name                = "plan-ds-${var.company_name}-${var.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Linux"
  sku_name            = var.ds_service_plan_sku
  worker_count        = var.app_service_plan_worker_count
  tags                = local.common_tags
}

module "app_service_plan_sm" {
  source = "../modules/_infra/app-service-plan"

  name                = "plan-sm-${var.company_name}-${var.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Windows"
  sku_name            = var.sm_service_plan_sku
  worker_count        = var.app_service_plan_worker_count
  tags                = local.common_tags
}

module "app_service_plan_ai" {
  count  = var.enable_ai ? 1 : 0
  source = "../modules/_infra/app-service-plan"

  name                = "plan-ai-${var.company_name}-${var.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = "Linux"
  sku_name            = var.ai_service_plan_sku
  worker_count        = var.app_service_plan_worker_count
  tags                = local.common_tags
}

# Alerting Infrastructure - Moved to app layer since it depends on monitoring