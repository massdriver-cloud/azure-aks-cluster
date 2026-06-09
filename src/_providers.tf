terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  client_id       = var.azure_authentication.client_id
  tenant_id       = var.azure_authentication.tenant_id
  client_secret   = var.azure_authentication.client_secret
  subscription_id = var.azure_authentication.subscription_id
}

provider "azuread" {
  client_id     = var.azure_authentication.client_id
  tenant_id     = var.azure_authentication.tenant_id
  client_secret = var.azure_authentication.client_secret
}
