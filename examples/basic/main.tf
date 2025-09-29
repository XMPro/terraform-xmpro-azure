# Basic XMPro Platform Deployment Example
# This example demonstrates a complete XMPro platform deployment on Azure

module "xmpro_platform" {
  # Use the latest version from GitHub
  # source = "github.com/XMPro/terraform-xmpro-azure"

  # For local development:
  source = "../../"

  # For specific latest stable released version:
  # source = "github.com/XMPro/terraform-xmpro-azure?ref=v4.5.3"

  # Core settings - customize these for your local testing
  environment = var.environment
  location    = var.location

  # Company information
  company_name                = var.company_name
  company_admin_first_name    = var.company_admin_first_name
  company_admin_last_name     = var.company_admin_last_name
  company_admin_email_address = var.company_admin_email_address

  # Database configuration
  db_admin_username          = var.db_admin_username
  db_admin_password          = var.db_admin_password
  company_admin_password     = var.company_admin_password
  site_admin_password        = var.site_admin_password
  db_sku_name                = var.db_sku_name
  db_max_size_gb             = var.db_max_size_gb
  db_collation               = var.db_collation
  db_zone_redundant          = var.db_zone_redundant
  db_allow_all_ips           = var.db_allow_all_ips
  create_local_firewall_rule = var.create_local_firewall_rule

  # Docker registry
  acr_url_product     = var.acr_url_product
  acr_username        = var.acr_username
  acr_password        = var.acr_password
  is_private_registry = var.is_private_registry

  # Local-specific settings
  imageversion = var.imageversion

  # DNS configuration - customize for your testing
  enable_custom_domain  = var.enable_custom_domain
  dns_zone_name         = var.dns_zone_name
  use_existing_dns_zone = var.use_existing_dns_zone

  # SMTP configuration
  enable_email_notification = var.enable_email_notification
  smtp_server               = var.smtp_server
  smtp_from_address         = var.smtp_from_address
  smtp_username             = var.smtp_username
  smtp_password             = var.smtp_password
  smtp_port                 = var.smtp_port
  smtp_enable_ssl           = var.smtp_enable_ssl

  # Security Headers Configuration
  enable_security_headers = var.enable_security_headers

  # Resource tagging
  tags = var.tags

  # Evaluation mode
  is_evaluation_mode = var.is_evaluation_mode

  # Service Plan SKUs
  ad_service_plan_sku = var.ad_service_plan_sku
  ds_service_plan_sku = var.ds_service_plan_sku
  sm_service_plan_sku = var.sm_service_plan_sku

  # Stream Host Configuration
  stream_host_cpu                   = var.stream_host_cpu
  stream_host_memory                = var.stream_host_memory
  stream_host_environment_variables = var.stream_host_environment_variables

  # Redis Cache Configuration
  create_redis_cache = var.create_redis_cache

  # Auto Scale Configuration
  enable_auto_scale       = var.enable_auto_scale
  redis_connection_string = var.redis_connection_string

  # Master Data Configuration
  create_masterdata             = var.create_masterdata
  masterdata_db_admin_username  = var.masterdata_db_admin_username
  masterdata_db_admin_password  = var.masterdata_db_admin_password

  # AD Encryption Key
  ad_encryption_key = var.ad_encryption_key
}