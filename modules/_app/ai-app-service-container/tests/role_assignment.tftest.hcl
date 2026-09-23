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
}

variables {
  name_suffix                    = "test"
  location                       = "eastus"
  resource_group_name            = "rg-test"
  companyname                    = "testco"
  acr_url_product                = "xmpro.azurecr.io"
  db_connection_string           = "Server=tcp:sql.test,1433;Initial Catalog=AI;"
  ad_url                         = "https://ad.test"
  sm_url                         = "https://sm.test"
  ds_url                         = "https://ds.test"
  ai_url                         = "https://ai.test"
  app_insights_connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
  aidbmigrate_container_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerInstance/containerGroups/ai-dbmigrate-test"
  ai_key_vault_name              = "kv-test"
  ai_service_plan_name           = "plan-test"
}

run "role_assignment_pins_principal_type" {
  command = plan

  assert {
    condition     = azurerm_role_assignment.ai_identity_secrets[0].principal_type == "ServicePrincipal"
    error_message = "azurerm_role_assignment.ai_identity_secrets must set principal_type = \"ServicePrincipal\" (omitting it causes intermittent PrincipalNotFound on fresh identities)"
  }
}
