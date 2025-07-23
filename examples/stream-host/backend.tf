# State configuration for local environment
# Uses local backend for individual developer testing

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Local backend configuration for state storage
  # State will be stored locally on developer's machine
  backend "local" {
    path = "terraform.tfstate"
  }
}