# Random resources for application layer
# This file centralizes all random UUID and string generation for product IDs and keys

resource "random_uuid" "sm_id" {
  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
  }
}

# DS Collection identifiers
resource "random_uuid" "ds_collection_id" {
  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
  }
}

resource "random_string" "ds_collection_secret" {
  length  = 10
  upper   = true
  lower   = true
  numeric = true
  special = false

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
  }
}

# AD Encryption Key (generated if not provided)
resource "random_string" "ad_encryption_key" {
  count   = var.ad_encryption_key == "" ? 1 : 0
  length  = 32
  upper   = true
  lower   = true
  numeric = true
  special = false

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
  }
}

# AI Infrastructure Key (generated if not provided)
# 32 random bytes exposed as a base64 string, matching the format documented
# on InfrastructureKeyOptions.Key in src/Products/AI/AI.Core/Providers and the
# default baked into xmpro-run's AI container appsettings.json.
resource "random_bytes" "ai_infrastructure_key" {
  count  = (var.enable_ai && var.ai_infrastructure_key == "") ? 1 : 0
  length = 32

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "ai"
  }
}

# Product IDs (generated when not in evaluation mode)
resource "random_uuid" "ad_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "ad"
  }
}

resource "random_uuid" "ai_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix        = var.name_suffix
    company_name       = var.company_name
    service            = "ai"
    ai_service_enabled = var.enable_ai
  }
}

resource "random_uuid" "ds_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "ds"
  }
}

resource "random_uuid" "nb_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "nb"
  }
}

# Product Keys (generated when not in evaluation mode)
resource "random_uuid" "ad_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "ad"
    type         = "key"
  }
}

resource "random_uuid" "ai_product_key" {
  count = (var.enable_ai && !var.is_evaluation_mode) ? 1 : 0

  keepers = {
    name_suffix        = var.name_suffix
    company_name       = var.company_name
    service            = "ai"
    type               = "key"
    ai_service_enabled = var.enable_ai
  }
}

resource "random_uuid" "ds_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "ds"
    type         = "key"
  }
}

resource "random_uuid" "nb_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    name_suffix  = var.name_suffix
    company_name = var.company_name
    service      = "nb"
    type         = "key"
  }
}