variable "subscription_id" {
  type = string
}

variable "rg_name" {
  type    = string
  default = "terraform-backend-RG"
}

variable "storage_account" {
  type = object({
    name                     = string
    account_tier             = string
    account_replication_type = string
    account_kind             = string
    access_tier              = string
  })
  default = {
    name                     = "terraformstates"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind             = "StorageV2"
    access_tier              = "Hot"
  }
}

variable "container" {
  type = object({
    name        = string
    access_type = string
  })
  default = {
    name        = "remote-backend"
    access_type = "private"
  }
}

variable "mypublic_ip" {
  type = string
}

variable "key_vault_name" {
  default = "my-principal-keyvault"
}

