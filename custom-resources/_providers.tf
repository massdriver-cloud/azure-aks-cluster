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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.md_metadata.name_prefix
  resource_group_name = var.md_metadata.name_prefix
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  client_id       = var.azure_service_principal.data.client_id
  tenant_id       = var.azure_service_principal.data.tenant_id
  client_secret   = var.azure_service_principal.data.client_secret
  subscription_id = var.azure_service_principal.data.subscription_id
}

provider "azuread" {
  client_id     = var.azure_service_principal.data.client_id
  tenant_id     = var.azure_service_principal.data.tenant_id
  client_secret = var.azure_service_principal.data.client_secret
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
}
