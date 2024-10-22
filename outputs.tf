output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "service_principal_password" {
  description = "Service principal's client secret value"
  value       = azuread_service_principal_password.secret.value
  sensitive   = true
}

output "service_principal_tenant_id" {
  value     = azuread_service_principal.spn.application_tenant_id
  sensitive = true
}

output "service_principal_client_id" {
  description = "The Azure AD service principal's client ID."
  value       = azuread_service_principal.spn.client_id
}

output "application_client_id" {
  description = "The Azure AD application (client) ID."
  value       = azuread_application.terraform.client_id
}

output "application_password" {
  description = "The application password value"
  value       = azuread_application_password.app_password.value
  sensitive   = true
}

output "subscription_id" {
  value     = data.azurerm_subscription.primary.id
  sensitive = true
}