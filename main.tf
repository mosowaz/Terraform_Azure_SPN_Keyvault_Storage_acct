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

  blob_properties {
    delete_retention_policy {
      days = "30"
    }
    restore_policy {
      days = "21"
    }
    container_delete_retention_policy {
      days = "30"
    }
    versioning_enabled = true
    change_feed_enabled = true
  }
}
resource "azurerm_storage_container" "container" {
  name                  = var.container.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.container.access_type
}
/*
resource "azurerm_storage_blob" "example" {
  name                   = "${azurerm_storage_container.container.name}-blob"
  storage_account_name   = azurerm_storage_account.storage
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}*/