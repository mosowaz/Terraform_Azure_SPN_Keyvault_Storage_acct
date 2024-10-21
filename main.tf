resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = "canadacentral"
}

resource "random_id" "rand" {
  byte_length = 2
}

resource "azurerm_storage_account" "storage" {
  name                          = "${var.storage_account.name}${random_id.rand.dec}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = var.storage_account.account_tier
  account_replication_type      = var.storage_account.account_replication_type
  account_kind                  = var.storage_account.account_kind
  access_tier                   = var.storage_account.access_tier
  shared_access_key_enabled     = false
  public_network_access_enabled = true
  default_to_oauth_authentication = true

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

resource "time_rotating" "monthly" {
  rotation_days = 30
}

resource "azuread_application" "terraform" {
  display_name = "Terraform-SPN"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "app_password" {
  application_id = azuread_application.terraform.id
  rotate_when_changed = {
    rotation = time_rotating.monthly.id
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
    rotation = time_rotating.monthly.id
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.spn.object_id
}