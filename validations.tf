# =============================================================================
# TERRAFORM VALIDATIONS
# =============================================================================
# This file contains all cross-variable validation logic for the module.
# Validations use terraform_data resources with lifecycle preconditions to
# provide early feedback during terraform plan/apply operations.
# =============================================================================

# -----------------------------------------------------------------------------
# Existing Database Configuration Validation
# -----------------------------------------------------------------------------
# Validates that all required variables are provided when use_existing_database = true
# This prevents users from accidentally enabling existing database mode without
# providing the necessary connection details and product IDs/keys.
resource "terraform_data" "existing_db_validation" {
  lifecycle {
    precondition {
      condition = !var.use_existing_database || (
        var.existing_sql_server_fqdn != "" &&
        var.existing_sm_product_id != "" &&
        var.existing_ad_product_id != "" &&
        var.existing_ds_product_id != "" &&
        var.existing_ad_product_key != "" &&
        var.existing_ds_product_key != "" &&
        (!var.enable_ai || (var.existing_ai_product_id != "" && var.existing_ai_product_key != ""))
      )
      error_message = "When use_existing_database=true, all existing database variables must be provided: existing_sql_server_fqdn, existing_sm_product_id, existing_ad_product_id, existing_ds_product_id, existing_ad_product_key, existing_ds_product_key. If enable_ai=true, also required: existing_ai_product_id, existing_ai_product_key"
    }
  }
}

# -----------------------------------------------------------------------------
# Redis Auto-Scale Configuration Validation
# -----------------------------------------------------------------------------
# Validates that redis_connection_string is provided when auto-scaling is enabled
# Exception: When create_redis_cache is true, the connection string will be
# automatically generated from the created Redis cache
resource "terraform_data" "auto_scale_validation" {
  lifecycle {
    precondition {
      condition     = !var.enable_auto_scale || var.redis_connection_string != "" || var.create_redis_cache
      error_message = "When enable_auto_scale=true, either provide redis_connection_string or set create_redis_cache=true. Format: 'your-redis.redis.cache.windows.net:6380,password=...,ssl=True,abortConnect=False'"
    }
  }
}

# -----------------------------------------------------------------------------
# Future Validation Placeholders
# -----------------------------------------------------------------------------
# Add additional validation resources here as needed:
#
# Example structure for future validations:
# resource "terraform_data" "custom_domain_validation" {
#   lifecycle {
#     precondition {
#       condition     = !var.enable_custom_domain || var.dns_zone_name != ""
#       error_message = "When enable_custom_domain=true, dns_zone_name must be provided"
#     }
#   }
# }
#
# resource "terraform_data" "ai_service_validation" {
#   lifecycle {
#     precondition {
#       condition     = !var.enable_ai || var.ai_service_plan_sku != ""
#       error_message = "When enable_ai=true, ai_service_plan_sku must be provided"
#     }
#   }
# }