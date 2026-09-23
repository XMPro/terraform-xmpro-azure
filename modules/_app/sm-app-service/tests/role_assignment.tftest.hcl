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
  tenant_id              = "00000000-0000-0000-0000-000000000000"
  name_suffix            = "test"
  location               = "eastus"
  resource_group_name    = "rg-test"
  companyname            = "testco"
  db_connection_string   = "Server=tcp:sql.test,1433;Initial Catalog=SM;"
  db_admin_username      = "sqladmin"
  db_admin_password      = "dummy-password"
  company_admin_password = "dummy-password"
  site_admin_password    = "dummy-password"
  sql_server_fqdn        = "sql.test.database.windows.net"
  storage_account_name   = "sttest"
  sm_service_plan_name   = "plan-test"
  sm_key_vault_name      = "kv-test"
  certificate_pfx_blob   = "ZHVtbXk="
  github_release_version = "5.0.0"
}

run "role_assignments_pin_principal_type" {
  command = plan

  assert {
    condition     = azurerm_role_assignment.sm_identity_secrets[0].principal_type == "ServicePrincipal"
    error_message = "azurerm_role_assignment.sm_identity_secrets must set principal_type = \"ServicePrincipal\" (omitting it causes intermittent PrincipalNotFound on fresh identities)"
  }

  assert {
    condition     = azurerm_role_assignment.sm_identity_certificates[0].principal_type == "ServicePrincipal"
    error_message = "azurerm_role_assignment.sm_identity_certificates must set principal_type = \"ServicePrincipal\" (omitting it causes intermittent PrincipalNotFound on fresh identities)"
  }
}
