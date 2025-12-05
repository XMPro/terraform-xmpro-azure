# Application Layer - XMPro Application Services
# This module contains application deployments like App Services, database migrations,
# and containers that run the XMPro platform

# Get current Azure context
data "azurerm_client_config" "current" {}

# Data sources for existing infrastructure resources
data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Data sources for monitoring resources from infrastructure layer
data "azurerm_application_insights" "this" {
  count               = var.app_insights_name != "" ? 1 : 0
  name                = var.app_insights_name
  resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace_name != "" ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Data sources for networking resources (when enabled)
data "azurerm_virtual_network" "this" {
  count               = var.prod_networking_enabled ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "presentation" {
  count                = var.prod_networking_enabled && try(var.subnet_names.presentation, "") != "" ? 1 : 0
  name                 = var.subnet_names.presentation
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "data" {
  count                = var.prod_networking_enabled && try(var.subnet_names.data, "") != "" ? 1 : 0
  name                 = var.subnet_names.data
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "aci" {
  count                = var.prod_networking_enabled && try(var.subnet_names.aci, "") != "" ? 1 : 0
  name                 = var.subnet_names.aci
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "processing" {
  count                = var.prod_networking_enabled && try(var.subnet_names.processing, "") != "" ? 1 : 0
  name                 = var.subnet_names.processing
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

# Private DNS zone for App Services (when private endpoints enabled)
data "azurerm_private_dns_zone" "sites" {
  count               = var.prod_networking_enabled && var.private_dns_zone_sites_name != "" ? 1 : 0
  name                = var.private_dns_zone_sites_name
  resource_group_name = var.resource_group_name
}

# Generate SAS token if not provided from infrastructure
data "azurerm_storage_account_sas" "this" {
  count = var.storage_sas_token == "" ? 1 : 0

  connection_string = data.azurerm_storage_account.this.primary_connection_string
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
  expiry = "2028-01-01T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
    tag     = false
    filter  = false
  }
}

# ============================================================================
# KEY VAULT MANAGED IDENTITIES (Always Created)
# ============================================================================
# Used for Key Vault access, created regardless of database authentication mode

resource "azurerm_user_assigned_identity" "sm_kv" {
  name                = coalesce(var.name_sm_kv_identity, "mi-${var.company_name}-sm-kv-${var.name_suffix}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.common_tags
}

resource "azurerm_user_assigned_identity" "ad_kv" {
  name                = coalesce(var.name_ad_kv_identity, "mi-${var.company_name}-ad-kv-${var.name_suffix}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.common_tags
}

resource "azurerm_user_assigned_identity" "ds_kv" {
  name                = coalesce(var.name_ds_kv_identity, "mi-${var.company_name}-ds-kv-${var.name_suffix}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.common_tags
}

resource "azurerm_user_assigned_identity" "ai_kv" {
  count               = var.enable_ai ? 1 : 0
  name                = coalesce(var.name_ai_kv_identity, "mi-${var.company_name}-ai-kv-${var.name_suffix}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.common_tags
}

locals {
  storage_sas_token = var.storage_sas_token != "" ? var.storage_sas_token : data.azurerm_storage_account_sas.this[0].sas
}

# DNS Zone Configuration (application-specific configurations)
module "dns_zone" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "../modules/_app/dns-zone"

  # Use infrastructure DNS zone
  dns_zone_name       = var.dns_zone_name
  resource_group_name = var.resource_group_name

  # DNS records and hostname bindings for applications
  domain_verification_records = merge({
    "ad" = {
      verification_id = module.ad_app_service.app_service_custom_domain_verification_id
    },
    "ds" = {
      verification_id = module.ds_app_service.app_service_custom_domain_verification_id
    },
    "sm" = {
      verification_id = module.sm_app_service.app_service_custom_domain_verification_id
    }
    }, var.enable_ai ? {
    "ai" = {
      verification_id = module.ai_app_service[0].app_service_custom_domain_verification_id
    }
  } : {})

  cname_records = merge({
    "ad" = {
      record = module.ad_app_service.app_service_default_hostname
    },
    "ds" = {
      record = module.ds_app_service.app_service_default_hostname
    },
    "sm" = {
      record = module.sm_app_service.app_service_default_hostname
    }
    }, var.enable_ai ? {
    "ai" = {
      record = module.ai_app_service[0].app_service_default_hostname
    }
  } : {})

  hostname_bindings = merge({
    "ad" = {
      app_service_name = module.ad_app_service.app_name
    },
    "ds" = {
      app_service_name = module.ds_app_service.app_name
    },
    "sm" = {
      app_service_name = module.sm_app_service.app_name
    }
    }, var.enable_ai ? {
    "ai" = {
      app_service_name = module.ai_app_service[0].app_name
    }
  } : {})

  tags = var.common_tags
}

# AD App Service
module "ad_app_service" {
  source = "../modules/_app/ad-app-service-container"

  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  companyname               = var.company_name
  name_suffix               = "${var.company_name}-${var.name_suffix}"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = var.enable_rbac_authorization

  # Key Vault and Service Plan from infrastructure
  ad_key_vault_name    = var.ad_key_vault_name
  ad_service_plan_name = var.ad_service_plan_name

  # Docker configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry
  docker_image_name   = "ad:${var.imageversion}"

  # Database configuration
  db_connection_string = local.ad_connection_string

  # URLs - use predefined URLs to avoid circular dependencies
  ad_url = local.ad_base_url
  sm_url = local.sm_base_url
  ai_url = local.ai_base_url
  ds_url = local.ds_base_url

  # App Insights
  app_insights_connection_string = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : ""

  # Environment settings
  aspnetcore_environment = var.aspnetcore_environment

  # SMTP Configuration
  enable_email_notification = var.enable_email_notification
  smtp_server               = var.smtp_server
  smtp_from_address         = var.smtp_from_address
  smtp_username             = var.smtp_username
  smtp_password             = var.smtp_password
  smtp_port                 = var.smtp_port
  smtp_enable_ssl           = var.smtp_enable_ssl

  # Security Headers Configuration
  enable_security_headers = var.enable_security_headers

  # Product ID and Key Configuration
  ad_product_id  = local.effective_ad_product_id
  ad_product_key = local.effective_ad_product_key

  # Encryption Key Configuration
  ad_encryption_key = local.effective_ad_encryption_key

  # Redis and Auto-scaling Configuration
  enable_auto_scale = var.enable_auto_scale
  redis_connection_string = var.enable_auto_scale ? (
    var.create_redis_cache
    ? try(var.redis_primary_connection_string, var.redis_connection_string)
    : var.redis_connection_string
  ) : ""

  # Create implicit dependency on ad_dbmigrate container (only when using new databases)
  addbmigrate_container_id = module.ad_dbmigrate.container_group_id

  # Networking configuration
  virtual_network_subnet_id     = var.prod_networking_enabled ? data.azurerm_subnet.presentation[0].id : null
  vnet_route_all_enabled        = var.prod_networking_enabled
  public_network_access_enabled = var.override_public_access ? true : !var.prod_networking_enabled

  # Custom resource naming (optional)
  custom_app_service_name = var.name_ad_app_service
  custom_identity_name    = var.name_ad_kv_identity

  # Don't create identity internally - using external KV+DB identities
  create_identity = false

  # Key Vault identity (from app layer - always present)
  kv_identity_id           = azurerm_user_assigned_identity.ad_kv.id
  kv_identity_client_id    = azurerm_user_assigned_identity.ad_kv.client_id
  kv_identity_principal_id = azurerm_user_assigned_identity.ad_kv.principal_id

  # Database identity (from infrastructure layer - only when AAD SQL auth enabled)
  db_identity_id        = local.ad_db_identity_resource_id
  db_identity_client_id = var.ad_db_aad_client_id

  # RBAC role names (optional - for custom roles)
  keyvault_secrets_reader_role_name = var.keyvault_secrets_reader_role_name

  # Tags
  tags = var.common_tags
}

# DS App Service
module "ds_app_service" {
  source = "../modules/_app/ds-app-service-container"

  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  companyname               = var.company_name
  name_suffix               = "${var.company_name}-${var.name_suffix}"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = var.enable_rbac_authorization

  # Key Vault and Service Plan from infrastructure
  ds_key_vault_name    = var.ds_key_vault_name
  ds_service_plan_name = var.ds_service_plan_name

  # Docker configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry
  docker_image_name   = "ds:${var.imageversion}"

  # Database configuration
  db_connection_string = local.ds_connection_string

  # URLs - use predefined URLs to avoid circular dependencies
  ds_url = local.ds_base_url
  sm_url = local.sm_base_url
  ad_url = local.ad_base_url
  ai_url = local.ai_base_url

  # App Insights
  app_insights_connection_string = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : ""

  # Environment settings
  aspnetcore_environment = var.aspnetcore_environment

  # Security Headers Configuration
  enable_security_headers = var.enable_security_headers

  # Product ID and Key Configuration
  ds_product_id  = local.effective_ds_product_id
  ds_product_key = local.effective_ds_product_key

  # Redis and Auto-scaling Configuration
  enable_auto_scale = var.enable_auto_scale
  redis_connection_string = var.enable_auto_scale ? (
    var.create_redis_cache
    ? try(var.redis_primary_connection_string, var.redis_connection_string)
    : var.redis_connection_string
  ) : ""

  # Create implicit dependency on ds_dbmigrate container (only when using new databases)
  dsdbmigrate_container_id = module.ds_dbmigrate.container_group_id

  # StreamHost download URL
  streamhost_download_base_url = var.streamhost_download_base_url

  # Networking configuration
  virtual_network_subnet_id     = var.prod_networking_enabled ? data.azurerm_subnet.presentation[0].id : null
  vnet_route_all_enabled        = var.prod_networking_enabled
  public_network_access_enabled = var.override_public_access ? true : !var.prod_networking_enabled

  # Custom resource naming (optional)
  custom_app_service_name = var.name_ds_app_service
  custom_identity_name    = var.name_ds_kv_identity

  # Don't create identity internally - using external KV+DB identities
  create_identity = false

  # Key Vault identity (from app layer - always present)
  kv_identity_id           = azurerm_user_assigned_identity.ds_kv.id
  kv_identity_client_id    = azurerm_user_assigned_identity.ds_kv.client_id
  kv_identity_principal_id = azurerm_user_assigned_identity.ds_kv.principal_id

  # Database identity (from infrastructure layer - only when AAD SQL auth enabled)
  db_identity_id        = local.ds_db_identity_resource_id
  db_identity_client_id = var.ds_db_aad_client_id

  # RBAC role names (optional - for custom roles)
  keyvault_secrets_reader_role_name = var.keyvault_secrets_reader_role_name

  # Tags
  tags = var.common_tags
}

# SM Database Migration (only when creating new databases)
module "sm_dbmigrate" {
  source = "../modules/_app/sm-dbmigrate"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration (use AAD auth connection string for migration container)
  db_connection_string   = local.sm_dbmigrate_connection_string
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  sm_database_id         = var.use_existing_database ? "" : var.sm_database_id

  # Company Admin Configuration
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address
  company_admin_username      = local.company_admin_username

  # URLs - use predefined URLs to avoid circular dependencies
  ad_url = local.ad_base_url
  ds_url = local.ds_base_url
  ai_url = local.ai_base_url
  nb_url = local.nb_base_url

  # Image version
  imageversion = var.imageversion

  # SM product ID
  sm_product_id = random_uuid.sm_id.result

  # Evaluation Mode Configuration
  product_ids  = local.evaluation_product_ids
  product_keys = local.evaluation_product_keys

  is_evaluation_mode = var.is_evaluation_mode

  # User-assigned identity for AAD SQL auth (use SM app identity)
  user_assigned_identity_id = local.sm_db_identity_resource_id

  # Tags
  tags = var.common_tags
}

# AD Database Migration (only when creating new databases)
module "ad_dbmigrate" {
  source = "../modules/_app/ad-dbmigrate"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration
  db_connection_string = local.ad_connection_string
  ad_database_id       = var.use_existing_database ? "" : var.ad_database_id

  # DS URL for environment variable
  ds_url = local.ds_base_url

  # Image version
  imageversion = var.imageversion

  # User-assigned identity for AAD SQL auth (use AD app identity)
  user_assigned_identity_id = local.ad_db_identity_resource_id

  # Tags
  tags = var.common_tags
}

# DS Database Migration (only when creating new databases)
module "ds_dbmigrate" {
  source = "../modules/_app/ds-dbmigrate"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container configuration
  is_private_registry = var.is_private_registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password

  # Collection configuration
  collection_id     = local.ds_collection_id
  collection_secret = local.ds_collection_secret

  # Database configuration
  db_connection_string = local.ds_connection_string
  ds_database_id       = var.use_existing_database ? "" : var.ds_database_id

  # Image version
  imageversion = var.imageversion

  # User-assigned identity for AAD SQL auth (use DS app identity)
  user_assigned_identity_id = local.ds_db_identity_resource_id

  # Tags
  tags = var.common_tags
}

# AI Database Migration (conditional)
module "ai_dbmigrate" {
  count  = var.enable_ai ? 1 : 0
  source = "../modules/_app/ai-dbmigrate"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration
  db_connection_string = local.ai_connection_string
  ai_database_id       = var.use_existing_database ? "" : var.ai_database_id

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = var.common_tags
}

# AI App Service (conditional)
module "ai_app_service" {
  count  = var.enable_ai ? 1 : 0
  source = "../modules/_app/ai-app-service-container"

  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${var.name_suffix}"

  # Key Vault and Service Plan from infrastructure (conditional on AI being enabled)
  ai_key_vault_name    = var.ai_key_vault_name
  ai_service_plan_name = var.ai_service_plan_name

  # Docker configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry
  docker_image_name   = "ai:${var.imageversion}"

  # Database configuration
  db_connection_string = local.ai_connection_string

  # URLs - use predefined URLs to avoid circular dependencies
  ai_url = local.ai_base_url
  sm_url = local.sm_base_url
  ad_url = local.ad_base_url
  ds_url = local.ds_base_url

  # App Insights
  app_insights_connection_string = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : ""

  # Environment settings
  aspnetcore_environment = var.aspnetcore_environment

  # Product ID and Key Configuration (following AD pattern)
  ai_product_id  = local.effective_ai_product_id
  ai_product_key = local.effective_ai_product_key

  # Create implicit dependency on ai_dbmigrate container
  aidbmigrate_container_id = var.enable_ai ? module.ai_dbmigrate[0].container_group_id : ""

  # Networking configuration
  virtual_network_subnet_id     = var.prod_networking_enabled ? data.azurerm_subnet.presentation[0].id : null
  vnet_route_all_enabled        = var.prod_networking_enabled
  public_network_access_enabled = var.override_public_access ? true : !var.prod_networking_enabled

  # Custom resource naming (optional)
  custom_app_service_name = var.name_ai_app_service
  custom_identity_name    = var.name_ai_kv_identity

  # RBAC role names (optional - for custom roles)
  keyvault_secrets_reader_role_name = var.keyvault_secrets_reader_role_name

  # Tags
  tags = var.common_tags
}

# Private Endpoints for App Services (when prod networking is enabled)

# AD Private Endpoint
module "ad_private_endpoint" {
  count  = var.prod_networking_enabled ? 1 : 0
  source = "../modules/_app/app-service-private-endpoint"

  name                = "pe-${module.ad_app_service.app_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.data[0].id
  app_service_id      = module.ad_app_service.app_id
  private_dns_zone_id = var.private_dns_zone_sites_name != "" ? data.azurerm_private_dns_zone.sites[0].id : ""
  tags                = var.common_tags
}

# DS Private Endpoint
module "ds_private_endpoint" {
  count  = var.prod_networking_enabled ? 1 : 0
  source = "../modules/_app/app-service-private-endpoint"

  name                = "pe-${module.ds_app_service.app_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.data[0].id
  app_service_id      = module.ds_app_service.app_id
  private_dns_zone_id = var.private_dns_zone_sites_name != "" ? data.azurerm_private_dns_zone.sites[0].id : ""
  tags                = var.common_tags
}

# SM Private Endpoint
module "sm_private_endpoint" {
  count  = var.prod_networking_enabled ? 1 : 0
  source = "../modules/_app/app-service-private-endpoint"

  name                = "pe-${module.sm_app_service.app_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.data[0].id
  app_service_id      = module.sm_app_service.app_id
  private_dns_zone_id = var.private_dns_zone_sites_name != "" ? data.azurerm_private_dns_zone.sites[0].id : ""
  tags                = var.common_tags
}

# AI Private Endpoint (conditional)
module "ai_private_endpoint" {
  count  = var.prod_networking_enabled && var.enable_ai ? 1 : 0
  source = "../modules/_app/app-service-private-endpoint"

  name                = "pe-${module.ai_app_service[0].app_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.data[0].id
  app_service_id      = module.ai_app_service[0].app_id
  private_dns_zone_id = var.private_dns_zone_sites_name != "" ? data.azurerm_private_dns_zone.sites[0].id : ""
  tags                = var.common_tags
}

# SM Preparation Container Module (creates SM.zip first)
module "sm_prep_container" {
  source = "../modules/_app/sm-prep-container"

  # Basic configuration
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Storage configuration - using infrastructure outputs
  storage_account_name = var.storage_account_name
  storage_account_key  = data.azurerm_storage_account.this.primary_access_key
  storage_share_id     = "https://${var.storage_account_name}.file.core.windows.net/sm-zip-prep-share"
  share_name           = "sm-zip-prep-share"

  # SM.zip download configuration
  sm_zip_download_url = var.sm_zip_download_url
  release_version     = var.imageversion

  # Key Vault configuration - use the same name passed from infrastructure layer
  azure_key_vault_name = var.sm_key_vault_name

  # Container registry configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # SSO Configuration
  sso_enabled             = var.sso_enabled
  sso_azure_ad_client_id  = var.sso_azure_ad_client_id
  sso_azure_ad_secret     = var.sso_azure_ad_secret
  sso_business_role_claim = var.sso_business_role_claim
  sso_azure_ad_tenant_id  = var.sso_azure_ad_tenant_id

  # Tags
  tags = var.common_tags
}

# Licenses Container (only when creating new databases)
module "licenses_container" {
  count  = var.is_evaluation_mode && !var.use_existing_database ? 1 : 0
  source = "../modules/_app/licenses-container"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_id          = var.company_id
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container Registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database Configuration
  sql_server_fqdn          = local.sql_server_fqdn
  db_admin_username        = var.db_admin_username
  db_admin_password        = var.db_admin_password
  smdbmigrate_container_id = module.sm_dbmigrate.container_group_id

  # Product IDs - use effective product IDs based on evaluation mode
  ad_product_id = local.effective_ad_product_id
  ds_product_id = local.effective_ds_product_id
  ai_product_id = local.effective_ai_product_id

  # License API
  license_api_url = var.license_api_url

  # Database and Company Configuration
  sm_database_name = var.sm_database_name

  # Container Image
  imageversion = var.imageversion

  # User-assigned identity for AAD SQL auth (use SM app identity)
  user_assigned_identity_id = local.sm_db_identity_resource_id

  # Tags
  tags = var.common_tags
}

# SM Key Vault - Creates secrets and certificate
module "sm_key_vault" {
  source = "../modules/_app/sm-key-vault"

  # Basic configuration
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  companyname         = var.company_name
  name_suffix         = var.name_suffix
  sm_key_vault_name   = var.sm_key_vault_name

  # Database configuration
  db_admin_username = var.db_admin_username
  db_admin_password = var.db_admin_password
  sql_server_fqdn   = local.sql_server_fqdn
  sm_database_name  = var.sm_database_name

  # SM Product ID - use the effective one from locals
  sm_product_id = local.effective_sm_product_id

  # SMTP Configuration
  enable_email_notification = var.enable_email_notification
  smtp_server               = var.smtp_server
  smtp_from_address         = var.smtp_from_address
  smtp_username             = var.smtp_username
  smtp_password             = var.smtp_password
  smtp_port                 = var.smtp_port
  smtp_enable_ssl           = var.smtp_enable_ssl

  # SM Base URL for configuration
  sm_base_url = local.sm_base_url

  # SSO Configuration
  sso_enabled             = var.sso_enabled
  sso_azure_ad_client_id  = var.sso_azure_ad_client_id
  sso_azure_ad_secret     = var.sso_azure_ad_secret
  sso_business_role_claim = var.sso_business_role_claim
  sso_azure_ad_tenant_id  = var.sso_azure_ad_tenant_id

  # Auto Scale Configuration
  enable_auto_scale = var.enable_auto_scale
  redis_connection_string = var.enable_auto_scale ? (
    var.create_redis_cache
    ? try(var.redis_primary_connection_string, var.redis_connection_string)
    : var.redis_connection_string
  ) : ""

  # Tags
  tags = var.common_tags
}

# SM App Service Module
module "sm_app_service" {
  source = "../modules/_app/sm-app-service"

  # Basic configuration
  location                  = var.resource_group_location
  resource_group_name       = var.resource_group_name
  companyname               = var.company_name
  name_suffix               = "${var.company_name}-${var.name_suffix}"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = var.enable_rbac_authorization

  # Key Vault and Service Plan from infrastructure
  sm_key_vault_name    = var.sm_key_vault_name
  sm_service_plan_name = var.sm_service_plan_name

  # Certificate configuration - use from SM Key Vault module
  certificate_pfx_blob = module.sm_key_vault.certificate_pfx_blob

  # Database configuration
  db_admin_username    = var.db_admin_username
  db_admin_password    = var.db_admin_password
  db_connection_string = local.sm_connection_string
  sql_server_fqdn      = local.sql_server_fqdn

  # Storage configuration for deployment - using infrastructure outputs
  files_location       = "sm-zip-prep-share"
  storage_account_name = var.storage_account_name
  storage_sas_token    = local.storage_sas_token

  # GitHub release version for versioned zip file
  github_release_version = var.imageversion

  # Application passwords
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = var.common_tags

  # Create implicit dependency on sm-prep-container
  sm_prep_container_id = module.sm_prep_container.container_group_id

  # Networking configuration
  virtual_network_subnet_id     = var.prod_networking_enabled ? data.azurerm_subnet.presentation[0].id : null
  vnet_route_all_enabled        = var.prod_networking_enabled
  public_network_access_enabled = var.override_public_access ? true : !var.prod_networking_enabled

  # Custom resource naming (optional)
  custom_app_service_name = var.name_sm_app_service
  custom_identity_name    = var.name_sm_kv_identity

  # Don't create identity internally - using external KV+DB identities
  create_identity = false

  # Key Vault identity (from app layer - always present)
  kv_identity_id           = azurerm_user_assigned_identity.sm_kv.id
  kv_identity_client_id    = azurerm_user_assigned_identity.sm_kv.client_id
  kv_identity_principal_id = azurerm_user_assigned_identity.sm_kv.principal_id

  # Database identity (from infrastructure layer - only when AAD SQL auth enabled)
  db_identity_id        = local.sm_db_identity_resource_id
  db_identity_client_id = var.sm_db_aad_client_id

  # RBAC role names (optional - for custom roles)
  keyvault_secrets_reader_role_name      = var.keyvault_secrets_reader_role_name
  keyvault_certificates_reader_role_name = var.keyvault_certificates_reader_role_name

  # Explicit dependency: Ensure app service waits for Key Vault secrets and certificate
  depends_on = [module.sm_key_vault]
}

# Stream Host Container
module "stream_host_container" {
  count  = var.create_stream_host ? 1 : 0
  source = "../modules/_app/stream-host-container"

  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  company_name        = var.company_name
  name_suffix         = var.name_suffix

  # Container Registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Container Image
  imageversion        = var.imageversion
  stream_host_variant = var.stream_host_variant

  # Stream Host Configuration
  ds_server_url                 = local.ds_base_url
  stream_host_collection_id     = local.ds_collection_id
  stream_host_collection_secret = local.ds_collection_secret
  stream_host_cpu               = var.stream_host_cpu
  stream_host_memory            = var.stream_host_memory
  environment_variables         = var.stream_host_environment_variables

  # Monitoring Integration - using monitoring module outputs
  app_insights_connection_string   = length(data.azurerm_application_insights.this) > 0 ? data.azurerm_application_insights.this[0].connection_string : ""
  log_analytics_workspace_id       = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].workspace_id : ""
  log_analytics_primary_shared_key = length(data.azurerm_log_analytics_workspace.this) > 0 ? data.azurerm_log_analytics_workspace.this[0].primary_shared_key : ""

  # Custom resource naming (optional)
  custom_container_name = var.name_stream_host_container

  # Networking (VNet integration - Stream Host goes in ACI subnet)
  prod_networking_enabled = var.prod_networking_enabled
  subnet_id               = var.prod_networking_enabled ? data.azurerm_subnet.aci[0].id : null

  # Tags
  tags = var.common_tags
}