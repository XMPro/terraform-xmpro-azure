# Consolidated random value generation following Terraform best practices
# This file centralizes all random UUID and string generation for consistent management

# Core deployment identifiers
resource "random_id" "suffix" {
  byte_length = 4
  keepers = {
    company_name = var.company_name
    environment  = var.environment
  }
}

resource "random_uuid" "sm_id" {
  keepers = {
    environment  = var.environment
    company_name = var.company_name
  }
}

# DS Collection identifiers
resource "random_uuid" "ds_collection_id" {
  keepers = {
    environment  = var.environment
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
    environment  = var.environment
    company_name = var.company_name
  }
}

# Product IDs (generated when not in evaluation mode)
resource "random_uuid" "ad_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "ad"
  }
}

resource "random_uuid" "ai_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment        = var.environment
    company_name       = var.company_name
    service            = "ai"
    ai_service_enabled = var.enable_ai
  }
}

resource "random_uuid" "ds_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "ds"
  }
}

resource "random_uuid" "nb_product_id" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "nb"
  }
}

# Product Keys (generated when not in evaluation mode)
resource "random_uuid" "ad_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "ad"
    type         = "key"
  }
}

resource "random_uuid" "ai_product_key" {
  count = (var.enable_ai && !var.is_evaluation_mode) ? 1 : 0

  keepers = {
    environment        = var.environment
    company_name       = var.company_name
    service            = "ai"
    type               = "key"
    ai_service_enabled = var.enable_ai
  }
}

resource "random_uuid" "ds_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "ds"
    type         = "key"
  }
}

resource "random_uuid" "nb_product_key" {
  count = var.is_evaluation_mode ? 0 : 1

  keepers = {
    environment  = var.environment
    company_name = var.company_name
    service      = "nb"
    type         = "key"
  }
}