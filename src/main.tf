locals {
  aks_name = var.md_metadata.name_prefix

  network_profile = {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "170.10.0.1/16"
    service_cidr       = "10.1.0.0/16"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.vnet.specs.azure.region
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = local.aks_name
  location            = var.vnet.specs.azure.region
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${local.aks_name}-dns"
  oidc_issuer_enabled = false
  kubernetes_version  = var.kubernetes_version

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  default_node_pool {
    name           = "default"
    vm_size        = var.node_groups[0].node_size
    node_count     = 1
    vnet_subnet_id = var.vnet.data.infrastructure.default_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = local.network_profile.network_plugin
    network_policy     = local.network_profile.network_policy
    dns_service_ip     = local.network_profile.dns_service_ip
    docker_bridge_cidr = local.network_profile.docker_bridge_cidr
    service_cidr       = local.network_profile.service_cidr
  }

  tags = var.md_metadata.default_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = { for ng in var.node_groups : ng.name => ng }
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.node_size
  vnet_subnet_id        = var.vnet.data.infrastructure.default_subnet_id
  enable_auto_scaling   = true
  max_count             = each.value.max_size
  min_count             = each.value.min_size
  tags                  = var.md_metadata.default_tags
}

data "azurerm_client_config" "main" {
}

resource "azurerm_role_assignment" "aks_read_acr" {
  scope                = "/subscriptions/${data.azurerm_client_config.main.subscription_id}"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
