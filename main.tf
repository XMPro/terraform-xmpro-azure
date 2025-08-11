# Main Terraform configuration file
# Random resources are consolidated in randoms.tf


# Resource Group (adopting sandbox-sm-only naming approach)
module "resource_group" {
  source = "./modules/resource-group"

  name     = "rg-${var.company_name}-${var.environment}-${random_id.suffix.hex}"
  location = var.location
  tags = merge(local.common_tags, {
    "CreatedFor" = "${var.environment} Terraform App Service Containers module"
  })
}

# DNS Zone
module "dns_zone" {
  count  = var.enable_custom_domain ? 1 : 0
  source = "./modules/dns-zone"

  name                = var.dns_zone_name
  resource_group_name = module.resource_group.name
  tags                = local.common_tags

  # DNS records and hostname bindings
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
}

# Storage Account Module for SM file shares
module "storage_account" {
  source = "./modules/storage-account"

  name_prefix         = "st${substr(var.company_name, 0, 3)}${random_id.suffix.hex}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  file_shares = {
    "sm-zip-prep-share" = {
      quota = 5
    }
  }
  tags = merge(local.common_tags, {
    "Purpose" = "sm-deployment"
  })
}

# Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  company_name        = var.company_name
  environment         = var.environment
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.common_tags

  # Optional parameters
  enable_log_analytics = true
  enable_app_insights  = true
  app_insights_name    = "appinsights-${var.company_name}-${var.environment}"
}

# Database
module "database" {
  count  = var.use_existing_database ? 0 : 1 # Only create if not using existing database
  source = "./modules/database"

  company_name                 = var.company_name
  environment                  = var.environment
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  db_server_name               = "sqldb-${var.company_name}-${var.environment}-${random_id.suffix.hex}"

  databases = merge({
    "AD" = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    },
    "DS" = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    },
    "SM" = {
      collation      = var.db_collation
      max_size_gb    = var.db_max_size_gb
      read_scale     = false
      sku_name       = var.db_sku_name
      zone_redundant = var.db_zone_redundant
      create_mode    = "Default"
    }
    }, var.enable_ai ? {
    "AI" = {
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

  tags = local.common_tags
}

# Connection strings and URLs are defined in locals.tf

# AD App Service
module "ad_app_service" {
  source = "./modules/ad-app-service-container"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${local.name_suffix}"

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
  app_insights_connection_string = module.monitoring.app_insights_connection_string

  # Environment settings
  aspnetcore_environment = "dev"
  service_plan_sku       = var.ad_service_plan_sku

  # SMTP Configuration
  enable_email_notification = var.enable_email_notification
  smtp_server               = var.smtp_server
  smtp_from_address         = var.smtp_from_address
  smtp_username             = var.smtp_username
  smtp_password             = var.smtp_password
  smtp_port                 = var.smtp_port
  smtp_enable_ssl           = var.smtp_enable_ssl

  # Product ID and Key Configuration
  ad_product_id  = local.effective_ad_product_id
  ad_product_key = local.effective_ad_product_key

  # Create implicit dependency on ad_dbmigrate container (only when using new databases)
  addbmigrate_container_id = module.ad_dbmigrate.container_group_id

  # Tags
  tags = local.common_tags
}

# DS App Service
module "ds_app_service" {
  source = "./modules/ds-app-service-container"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${local.name_suffix}"

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
  app_insights_connection_string = module.monitoring.app_insights_connection_string

  # Environment settings
  aspnetcore_environment = "dev"
  service_plan_sku       = var.ds_service_plan_sku

  # Product ID and Key Configuration
  ds_product_id  = local.effective_ds_product_id
  ds_product_key = local.effective_ds_product_key

  # Create implicit dependency on ds_dbmigrate container (only when using new databases)
  dsdbmigrate_container_id = module.ds_dbmigrate.container_group_id

  # Tags
  tags = local.common_tags
}

# SM Database Migration (only when creating new databases)
module "sm_dbmigrate" {
  source = "./modules/sm-dbmigrate"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration
  db_connection_string   = local.sm_connection_string
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password
  sm_database_id         = var.use_existing_database ? "" : module.database[0].database_ids["SM"] # Create implicit dependency on SM database

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

  # Tags
  tags = local.common_tags
}

# SM Key Vault Module (top level for proper module composition)
module "sm_key_vault" {
  source = "./modules/sm-key-vault"

  # Pass through variables
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${random_id.suffix.hex}"
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  sql_server_fqdn     = local.sql_server_fqdn
  sm_product_id       = local.effective_sm_product_id

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

  # Tags
  tags = local.common_tags
}

# AD Database Migration (only when creating new databases)
module "ad_dbmigrate" {
  source = "./modules/ad-dbmigrate"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration
  db_connection_string = local.ad_connection_string
  ad_database_id       = var.use_existing_database ? "" : module.database[0].database_ids["AD"] # Create implicit dependency on AD database

  # DS URL for environment variable
  ds_url = local.ds_base_url

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = local.common_tags
}

# DS Database Migration (only when creating new databases)
module "ds_dbmigrate" {
  source = "./modules/ds-dbmigrate"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex

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
  ds_database_id       = var.use_existing_database ? "" : module.database[0].database_ids["DS"] # Create implicit dependency on DS database

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = local.common_tags
}

# AI Database Migration (conditional)
module "ai_dbmigrate" {
  count  = var.enable_ai ? 1 : 0
  source = "./modules/ai-dbmigrate"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex

  # Container configuration
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Database configuration
  db_connection_string = local.ai_connection_string
  ai_database_id       = var.use_existing_database ? "" : module.database[0].database_ids["AI"] # Create implicit dependency on AI database

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = local.common_tags
}

# AI App Service (conditional)
module "ai_app_service" {
  count  = var.enable_ai ? 1 : 0
  source = "./modules/ai-app-service-container"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${local.name_suffix}"

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
  app_insights_connection_string = module.monitoring.app_insights_connection_string

  # Environment settings
  aspnetcore_environment = "dev"
  service_plan_sku       = var.ai_service_plan_sku

  # Create implicit dependency on ai_dbmigrate container
  aidbmigrate_container_id = var.enable_ai ? module.ai_dbmigrate[0].container_group_id : ""

  # Tags
  tags = local.common_tags
}

# SM Preparation Container Module (creates SM.zip first)
module "sm_prep_container" {
  source = "./modules/sm-prep-container"

  # Basic configuration
  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name

  # Storage configuration
  storage_account_name = module.storage_account.name
  storage_account_key  = module.storage_account.primary_access_key
  storage_share_id     = module.storage_account.file_shares["sm-zip-prep-share"]
  share_name           = "sm-zip-prep-share"

  # SM.zip download configuration
  sm_zip_download_url = var.sm_zip_download_url
  release_version     = var.imageversion

  # Key Vault configuration (calculated name - no dependency needed)
  azure_key_vault_name = "kv-sm-${substr("${var.company_name}-${random_id.suffix.hex}", 0, 16)}"

  # Tags
  tags = local.common_tags
}

# Licenses Container (only when creating new databases)
module "licenses_container" {
  count  = var.is_evaluation_mode && !var.use_existing_database ? 1 : 0
  source = "./modules/licenses-container"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_id          = var.company_id # Default company ID for evaluation mode
  company_name        = var.company_name
  deployment_suffix   = random_id.suffix.hex

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
  sm_database_name = "SM"

  # Container Image
  imageversion = var.imageversion

  # Tags
  tags = local.common_tags
}

# SM App Service Module (uses Key Vault from top level)
module "sm_app_service" {
  source = "./modules/sm-app-service"

  # Basic configuration
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  companyname         = var.company_name
  name_suffix         = "${var.company_name}-${random_id.suffix.hex}"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Key Vault configuration (use Key Vault from top level)
  key_vault_id = module.sm_key_vault.id

  # Certificate configuration (pass PFX blob directly to eliminate data source dependency)
  certificate_pfx_blob = module.sm_key_vault.certificate_pfx_blob

  # Database configuration
  db_admin_username    = var.db_admin_username
  db_admin_password    = var.db_admin_password
  db_connection_string = local.sm_connection_string
  sql_server_fqdn      = local.sql_server_fqdn

  # App Service configuration
  service_plan_sku = var.sm_service_plan_sku

  # Storage configuration for deployment
  files_location       = "sm-zip-prep-share"
  storage_account_name = module.storage_account.name
  storage_sas_token    = module.storage_account.sas_token

  # GitHub release version for versioned zip file
  github_release_version = var.imageversion

  # Application passwords
  company_admin_password = var.company_admin_password
  site_admin_password    = var.site_admin_password

  # Image version
  imageversion = var.imageversion

  # Tags
  tags = local.common_tags

  # Create implicit dependency on sm-prep-container
  sm_prep_container_id = module.sm_prep_container.container_group_id

  # Explicit dependency: Ensure app service waits for prep container and Key Vault
  depends_on = [module.sm_prep_container, module.sm_key_vault]
}

# Stream Host Container (always deployed)
module "stream_host_container" {
  source = "./modules/stream-host-container"

  environment         = var.environment
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  company_name        = var.company_name
  name_suffix         = local.name_suffix

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

  # Monitoring Integration
  app_insights_connection_string   = module.monitoring.app_insights_connection_string
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  log_analytics_primary_shared_key = module.monitoring.log_analytics_primary_shared_key

  # Tags
  tags = local.common_tags
}
