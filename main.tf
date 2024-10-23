resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = "canadacentral"
}

resource "random_id" "rand" {
  byte_length = 2
}

resource "azurerm_storage_account" "storage" {
  name                            = "${var.storage_account.name}${random_id.rand.dec}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = var.storage_account.account_tier
  account_replication_type        = var.storage_account.account_replication_type
  account_kind                    = var.storage_account.account_kind
  access_tier                     = var.storage_account.access_tier
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
  default_to_oauth_authentication = true
  network_rules {
    default_action = "Deny"
    ip_rules       = [var.mypublic_ip]
  }

  blob_properties {
    delete_retention_policy {
      days = "30"
    }
    restore_policy {
      days = "23"
    }
    container_delete_retention_policy {
      days = "30"
    }
    versioning_enabled  = true
    change_feed_enabled = true
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.container.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.container.access_type
}

resource "time_rotating" "quarterly" {
  rotation_days = 90
}

resource "azuread_application" "terraform" {
  display_name = "Terraform-SPN"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "app_password" {
  application_id = azuread_application.terraform.id
  rotate_when_changed = {
    rotation = time_rotating.quarterly.id
  }
}

resource "azuread_service_principal" "spn" {
  client_id                    = azuread_application.terraform.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "secret" {
  service_principal_id = azuread_service_principal.spn.id
  rotate_when_changed = {
    rotation = time_rotating.quarterly.id
  }
}

resource "azurerm_role_assignment" "role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.spn.object_id
}

resource "azurerm_key_vault" "vault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  depends_on = [
    azuread_service_principal.spn, azuread_service_principal_password.secret
  ]
}

resource "azurerm_key_vault_access_policy" "access" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.spn.object_id

  key_permissions = [
    "Get", "List", "Encrypt", "Decrypt", "Create", "Delete",
    "Purge", "Recover", "Restore", "Update", "Rotate", "Backup"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  depends_on = [azurerm_key_vault.vault]
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = tomap({
    "client_id" = {
      name  = "SPN-client-id"
      value = azuread_application.terraform.client_id
    }
    "secret" = {
      name  = "SPN-client-secret"
      value = azuread_service_principal_password.secret.value
    }
    "tenant_id" = {
      name  = "SPN-tenant-id"
      value = azuread_service_principal.spn.application_tenant_id
    }
    "subscription_id" = {
      name  = "SPN-subscription-id"
      value = data.azurerm_subscription.primary.subscription_id
    }
  })
  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [azurerm_key_vault_access_policy.access]
}
