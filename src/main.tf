resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.vnet.specs.azure.region
  tags     = var.md_metadata.default_tags
}

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.cluster.enable_log_analytics ? 1 : 0
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.md_metadata.default_tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                              = var.md_metadata.name_prefix
  location                          = var.vnet.specs.azure.region
  resource_group_name               = azurerm_resource_group.main.name
  dns_prefix                        = "${var.md_metadata.name_prefix}-dns"
  kubernetes_version                = var.cluster.kubernetes_version
  oidc_issuer_enabled               = false
  azure_policy_enabled              = true
  role_based_access_control_enabled = true
  tags                              = var.md_metadata.default_tags

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  dynamic "oms_agent" {
    for_each = var.cluster.enable_log_analytics ? toset(["enabled"]) : toset([])
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
    }
  }

  default_node_pool {
    name                = var.node_groups.default_node_group.name
    vm_size             = var.node_groups.default_node_group.node_size
    min_count           = var.node_groups.default_node_group.min_size
    max_count           = var.node_groups.default_node_group.max_size
    vnet_subnet_id      = var.vnet.data.infrastructure.default_subnet_id
    enable_auto_scaling = true
    tags                = var.md_metadata.default_tags
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    dns_service_ip     = "172.20.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "172.20.0.0/16"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = { for ng in var.node_groups.additional_node_groups : ng.name => ng }
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
