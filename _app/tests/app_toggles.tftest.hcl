mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      subscription_id = "00000000-0000-0000-0000-000000000002"
      object_id       = "00000000-0000-0000-0000-000000000003"
      client_id       = "00000000-0000-0000-0000-000000000004"
    }
  }
  mock_data "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"
    }
  }
  mock_data "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.Web/serverFarms/plan-test"
    }
  }
  mock_data "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-test"
      principal_id = "00000000-0000-0000-0000-000000000005"
      client_id    = "00000000-0000-0000-0000-000000000006"
    }
  }
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      principal_id = "00000000-0000-0000-0000-000000000005"
      client_id    = "00000000-0000-0000-0000-000000000006"
    }
  }
  mock_data "azurerm_log_analytics_workspace" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/log-test"
      workspace_id       = "00000000-0000-0000-0000-000000000007"
      primary_shared_key = "ZHVtbXk="
    }
  }
  mock_data "azurerm_storage_account" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/sttest"
      primary_access_key        = "ZHVtbXk="
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=sttest;AccountKey=ZHVtbXk=;EndpointSuffix=core.windows.net"
    }
  }
  mock_data "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-test/providers/Microsoft.Insights/components/appi-test"
      instrumentation_key = "00000000-0000-0000-0000-000000000008"
      connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000008"
    }
  }
  mock_data "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    }
  }
  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-test"
    }
  }
  mock_data "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-network-test/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    }
  }
}

variables {
  name_suffix                      = "test"
  db_admin_password                = "XmPro-Dummy-Passw0rd#2026"
  log_analytics_workspace_name     = "log-test"
  tenant_id                        = "00000000-0000-0000-0000-000000000000"
  resource_group_name              = "rg-test"
  resource_group_location          = "eastus"
  sql_server_fqdn                  = "sql.test.database.windows.net"
  storage_account_name             = "sttest"
  log_analytics_workspace_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/log-test"
  log_analytics_primary_shared_key = "dummy-key"
  key_vault_certificate_pfx_blob   = "ZHVtbXk="
  company_admin_password           = "dummy-password"
  site_admin_password              = "dummy-password"
  email_oauth_token_endpoint       = "https://login.test/oauth2/token"
  ad_key_vault_name                = "kv-ad-test"
  ds_key_vault_name                = "kv-ds-test"
  sm_key_vault_name                = "kv-sm-test"
  ad_service_plan_name             = "plan-ad-test"
  ds_service_plan_name             = "plan-ds-test"
  sm_service_plan_name             = "plan-sm-test"
  subnet_names = {
    presentation = ""
    data         = ""
    aci          = ""
    processing   = ""
  }
}

run "sql_auth_connection_strings_trust_server_certificate" {
  command = plan

  assert {
    condition     = strcontains(local.ad_connection_string, "TrustServerCertificate=true")
    error_message = "AD SQL-auth connection string must carry TrustServerCertificate"
  }

  assert {
    condition     = strcontains(local.ds_connection_string, "TrustServerCertificate=true")
    error_message = "DS SQL-auth connection string must carry TrustServerCertificate"
  }

  assert {
    condition     = strcontains(local.ai_connection_string, "TrustServerCertificate=true")
    error_message = "AI SQL-auth connection string must carry TrustServerCertificate"
  }
}

run "aad_auth_connection_strings_disable_trust_server_certificate" {
  command = plan

  variables {
    enable_sql_aad_auth = true
  }

  assert {
    condition     = strcontains(local.ad_connection_string, "TrustServerCertificate=False")
    error_message = "AAD-auth connection strings must keep TrustServerCertificate=False"
  }
}

run "evaluation_mode_plans_licenses_container" {
  command = plan

  variables {
    is_evaluation_mode = true
  }

  assert {
    condition     = length(module.licenses_container) == 1
    error_message = "is_evaluation_mode = true must plan the licenses container"
  }
}

run "production_mode_skips_licenses_container" {
  command = plan

  variables {
    is_evaluation_mode = false
  }

  assert {
    condition     = length(module.licenses_container) == 0
    error_message = "is_evaluation_mode = false must not plan the licenses container"
  }
}

run "prod_networking_with_separate_vnet_rg_plans_private_endpoints" {
  command = plan

  variables {
    prod_networking_enabled     = true
    vnet_name                   = "vnet-test"
    network_resource_group_name = "rg-network-test"
    subnet_names = {
      presentation = "snet-presentation"
      data         = "snet-data"
      aci          = "snet-aci"
      processing   = "snet-processing"
    }
  }

  assert {
    condition     = length(module.ad_private_endpoint) == 1 && length(module.ds_private_endpoint) == 1 && length(module.sm_private_endpoint) == 1
    error_message = "prod networking with the VNet in a separate resource group must plan the AD/DS/SM private endpoints"
  }
}
