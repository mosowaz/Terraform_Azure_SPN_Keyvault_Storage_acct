terraform {
  required_version = "~> 1.9.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "random" {

}
provider "azuread" {
  # Configuration options
}

provider "azurerm" {
  features {
  }
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}