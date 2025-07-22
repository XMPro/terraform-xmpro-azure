# Terraform provider configuration
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2"
    }
  }
}

# Azure Provider configuration
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

