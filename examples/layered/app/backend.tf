# Backend configuration for application layer
# Uncomment and configure for remote state storage (e.g., Azure Storage, S3)
# For local development, comment out this file or use local backend

# Example: Azure Storage backend
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstate<unique>"
#     container_name       = "tfstate"
#     key                  = "xmpro-app.tfstate"
#   }
# }

# Example: Local backend for development
# terraform {
#   backend "local" {
#     path = "terraform-app.tfstate"
#   }
# }