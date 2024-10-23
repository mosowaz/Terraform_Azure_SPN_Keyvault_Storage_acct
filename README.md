# Terraform_Azure_SPN_Keyvault_Storage_acct

Utilizing Terraform to create Azure Service Principal, Key vault, and Storage account. Then storing the tfstate file in a storage blob as remote backend.

Multiple secrets can be stored in the key vault by utilizing terraform for_each metadata

```
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

```

Also note that the current user / service principal running terraform apply needs to grant permission to self in the key vault access policy block. Current user is  ``` data.azurerm_client_config.current.object_id ```

```
resource "azurerm_key_vault_access_policy" "access" {
  for_each = toset([ data.azurerm_client_config.current.object_id, 
                    data.azuread_service_principal.spn.object_id ])

  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  key_permissions = [
    "Get", "List", "Encrypt", "Decrypt", "Create", "Delete",
    "Purge", "Recover", "Restore", "Update", "Rotate", "Backup"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  depends_on = [azurerm_key_vault.vault]
}
```

