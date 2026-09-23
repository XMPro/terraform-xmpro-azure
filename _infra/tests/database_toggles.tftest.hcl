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
  name_suffix       = "test"
  db_admin_username = "sqladmin"
  db_admin_password = "XmPro-Dummy-Passw0rd#2026"
  subnet_address_prefixes = {
    presentation = "10.0.1.0/24"
    data         = "10.0.2.0/24"
    aci          = "10.0.3.0/24"
    processing   = "10.0.4.0/24"
  }
}

run "default_creates_sql_server_with_three_databases" {
  command = plan

  assert {
    condition     = length(module.database) == 1
    error_message = "default plan must create the SQL server (module.database)"
  }

  assert {
    condition     = length(module.database[0].database_ids) == 3
    error_message = "default plan must create exactly the AD, DS and SM databases"
  }
}

run "existing_database_skips_sql_resources" {
  command = plan

  variables {
    use_existing_database = true
  }

  assert {
    condition     = length(module.database) == 0
    error_message = "use_existing_database = true must not plan any SQL server or databases"
  }

  assert {
    condition     = length(module.aad_identities) == 0 && length(module.aad_container) == 0
    error_message = "use_existing_database = true must not plan AAD database identities or the AAD provisioning container"
  }
}

run "enable_ai_adds_exactly_one_database" {
  command = plan

  variables {
    enable_ai = true
  }

  assert {
    condition     = length(module.database[0].database_ids) == 4
    error_message = "enable_ai = true must add exactly one extra database (AI)"
  }
}
