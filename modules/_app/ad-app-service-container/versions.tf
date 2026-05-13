# Provider source declarations for this module
# azapi is required for setting siteConfig.minTlsCipherSuite on the App Service
# (azurerm does not expose this property — see open issues #24223, #24337, #25894)
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }
  }
}
