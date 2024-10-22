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
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}

provider "time" {}

provider "random" {}

provider "azuread" {}

provider "azurerm" {
  features {
  }
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}