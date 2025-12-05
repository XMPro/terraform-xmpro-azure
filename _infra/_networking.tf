# Enterprise Networking Infrastructure
# VNets, Subnets, Private Endpoints, DNS Zones

# Virtual Network
module "virtual_network" {
  source = "../modules/_infra/vnet"
  count  = var.prod_networking_enabled ? 1 : 0

  name                = "vnet-${var.company_name}-dev-${var.name_suffix}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space

  tags = merge(local.common_tags, {
    "Purpose" = "enterprise-networking"
  })
}

# Subnets for different tiers
module "subnets" {
  source = "../modules/_infra/subnets"
  count  = var.prod_networking_enabled ? 1 : 0

  virtual_network_name = module.virtual_network[0].name
  resource_group_name  = module.resource_group.name

  subnets = {
    # Subnet 1 - Presentation: App Services (AD, DS, SM) and Key Vaults
    "presentation" = {
      address_prefixes = [cidrsubnet(var.vnet_address_space[0], 4, 0)]
      service_endpoints = [
        "Microsoft.Web",
        "Microsoft.ContainerRegistry",
        "Microsoft.Sql"
      ]
      delegation = {
        name = "app-service-delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }

    # Subnet 2 - Data: SQL databases, Redis Cache, Storage (private endpoints)
    "data" = {
      address_prefixes                          = [cidrsubnet(var.vnet_address_space[0], 4, 1)]
      private_endpoint_network_policies_enabled = false
      service_endpoints = [
        "Microsoft.Sql",
        "Microsoft.Storage"
      ]
    }

    # Subnet 3 - ACI: Stream Host (Azure Container Instances)
    "aci" = {
      address_prefixes  = [cidrsubnet(var.vnet_address_space[0], 4, 2)]
      service_endpoints = []
      delegation = {
        name = "container-instance-delegation"
        service_delegation = {
          name = "Microsoft.ContainerInstance/containerGroups"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/action"
          ]
        }
      }
    }

    # Subnet 4 - Processing: AI services (Azure Open AI, AI Search, etc.)
    "processing" = {
      address_prefixes  = [cidrsubnet(var.vnet_address_space[0], 4, 3)]
      service_endpoints = []
    }
  }
}

# Network Security Groups
module "network_security_groups" {
  source = "../modules/_infra/network-security-group"
  count  = var.prod_networking_enabled ? 1 : 0

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  nsgs = {
    # NSG for Presentation subnet (App Services)
    "presentation" = {
      name = "nsg-presentation-dev-${var.name_suffix}"
      rules = [
        {
          name                       = "AllowHTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowHTTP"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        }
      ]
    }

    # NSG for Data subnet (SQL, Redis, Storage private endpoints)
    "data" = {
      name = "nsg-data-dev-${var.name_suffix}"
      rules = [
        {
          name                       = "AllowSqlFromPresentation"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = cidrsubnet(var.vnet_address_space[0], 4, 0)
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowSqlFromACI"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = cidrsubnet(var.vnet_address_space[0], 4, 2)
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowStorageFromPresentation"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = cidrsubnet(var.vnet_address_space[0], 4, 0)
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowStorageFromACI"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = cidrsubnet(var.vnet_address_space[0], 4, 2)
          destination_address_prefix = "*"
        }
      ]
    }

    # NSG for ACI subnet (Stream Host)
    "aci" = {
      name = "nsg-aci-dev-${var.name_suffix}"
      rules = [
        {
          name                       = "AllowVNetInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }
      ]
    }

    # NSG for Processing subnet (AI services)
    "processing" = {
      name = "nsg-processing-dev-${var.name_suffix}"
      rules = [
        {
          name                       = "AllowVNetInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "VirtualNetwork"
        }
      ]
    }
  }

  tags = merge(local.common_tags, {
    "Purpose" = "network-security"
  })
}

# NSG Associations - Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "presentation" {
  count = var.prod_networking_enabled ? 1 : 0

  subnet_id                 = module.subnets[0].subnet_ids["presentation"]
  network_security_group_id = module.network_security_groups[0].nsg_ids["presentation"]
}

resource "azurerm_subnet_network_security_group_association" "data" {
  count = var.prod_networking_enabled ? 1 : 0

  subnet_id                 = module.subnets[0].subnet_ids["data"]
  network_security_group_id = module.network_security_groups[0].nsg_ids["data"]
}

resource "azurerm_subnet_network_security_group_association" "aci" {
  count = var.prod_networking_enabled ? 1 : 0

  subnet_id                 = module.subnets[0].subnet_ids["aci"]
  network_security_group_id = module.network_security_groups[0].nsg_ids["aci"]
}

resource "azurerm_subnet_network_security_group_association" "processing" {
  count = var.prod_networking_enabled ? 1 : 0

  subnet_id                 = module.subnets[0].subnet_ids["processing"]
  network_security_group_id = module.network_security_groups[0].nsg_ids["processing"]
}

# Private DNS Zones for Azure services
module "private_dns_zones" {
  source = "../modules/_infra/private-dns-zones"
  count  = var.prod_networking_enabled ? 1 : 0

  resource_group_name = module.resource_group.name

  dns_zones = {
    # SQL Database
    "sql" = {
      name = "privatelink.database.windows.net"
    }
    # Key Vault
    "keyvault" = {
      name = "privatelink.vaultcore.azure.net"
    }
    # Storage - Blob
    "blob" = {
      name = "privatelink.blob.core.windows.net"
    }
    # Storage - File
    "file" = {
      name = "privatelink.file.core.windows.net"
    }
    # App Services
    "sites" = {
      name = "privatelink.azurewebsites.net"
    }
    # Container Registry
    "acr" = {
      name = "privatelink.azurecr.io"
    }
    # Redis Cache
    "redis" = {
      name = "privatelink.redis.cache.windows.net"
    }
  }

  # Link DNS zones to VNet
  virtual_network_id = module.virtual_network[0].id

  tags = merge(local.common_tags, {
    "Purpose" = "private-dns-resolution"
  })
}

# Private Endpoints for Data Tier Resources
module "private_endpoints" {
  source = "../modules/_infra/private-endpoints"
  count  = var.prod_networking_enabled ? 1 : 0

  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  subnet_id           = module.subnets[0].subnet_ids["data"]

  private_endpoints = merge(
    # SQL Server Private Endpoint
    var.use_existing_database ? {} : {
      sql = {
        name                = "pe-sql-${var.company_name}-${var.name_suffix}"
        resource_id         = module.database[0].sql_server_id
        subresource_name    = "sqlServer"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["sql"]
      }
    },
    # Storage Account Private Endpoints (blob and file)
    {
      storage_blob = {
        name                = "pe-st-blob-${var.company_name}-${var.name_suffix}"
        resource_id         = module.storage_account.id
        subresource_name    = "blob"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["blob"]
      }
      storage_file = {
        name                = "pe-st-file-${var.company_name}-${var.name_suffix}"
        resource_id         = module.storage_account.id
        subresource_name    = "file"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["file"]
      }
    },
    # Key Vault Private Endpoints
    {
      keyvault_ad = {
        name                = "pe-kv-ad-${var.company_name}-${var.name_suffix}"
        resource_id         = module.key_vault_ad.id
        subresource_name    = "vault"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["keyvault"]
      }
      keyvault_ds = {
        name                = "pe-kv-ds-${var.company_name}-${var.name_suffix}"
        resource_id         = module.key_vault_ds.id
        subresource_name    = "vault"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["keyvault"]
      }
      keyvault_sm = {
        name                = "pe-kv-sm-${var.company_name}-${var.name_suffix}"
        resource_id         = module.key_vault_sm.id
        subresource_name    = "vault"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["keyvault"]
      }
    },
    # AI Key Vault Private Endpoint (conditional on enable_ai)
    var.enable_ai ? {
      keyvault_ai = {
        name                = "pe-kv-ai-${var.company_name}-${var.name_suffix}"
        resource_id         = module.key_vault_ai[0].id
        subresource_name    = "vault"
        private_dns_zone_id = module.private_dns_zones[0].zone_ids["keyvault"]
      }
    } : {}
  )

  tags = merge(local.common_tags, {
    "Purpose" = "private-connectivity"
  })
}

# Outputs for use by other modules
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = var.prod_networking_enabled ? module.virtual_network[0].id : null
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = var.prod_networking_enabled ? module.virtual_network[0].name : null
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = var.prod_networking_enabled ? module.subnets[0].subnet_ids : {}
}

output "subnet_names" {
  description = "Map of subnet tier to subnet names"
  value       = var.prod_networking_enabled ? module.subnets[0].subnet_names : {}
}

output "private_dns_zone_ids" {
  description = "Map of DNS zone types to their IDs"
  value       = var.prod_networking_enabled ? module.private_dns_zones[0].zone_ids : {}
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = var.prod_networking_enabled ? module.network_security_groups[0].nsg_ids : {}
}

output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs"
  value       = var.prod_networking_enabled ? module.private_endpoints[0].private_endpoint_ids : {}
}

output "private_endpoint_ips" {
  description = "Map of private endpoint names to their private IP addresses"
  value       = var.prod_networking_enabled ? module.private_endpoints[0].private_endpoint_ips : {}
}