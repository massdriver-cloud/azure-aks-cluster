locals {
  node_rg_max_length = 80
  node_rg_name       = substr("MC_${var.md_metadata.name_prefix}_${var.md_metadata.name_prefix}_${var.vnet.specs.azure.region}", 0, local.node_rg_max_length)
}

resource "random_string" "temp_node_group" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}
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
  node_resource_group               = local.node_rg_name
  automatic_upgrade_channel         = "stable"
  azure_policy_enabled              = true
  role_based_access_control_enabled = true
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true
  tags                              = var.md_metadata.default_tags

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = []
  }

  dynamic "monitor_metrics" {
    for_each = var.cluster.enable_log_analytics ? toset(["enabled"]) : toset([])
    content {
      annotations_allowed = null
      labels_allowed      = null
    }
  }

  dynamic "oms_agent" {
    for_each = var.cluster.enable_log_analytics ? toset(["enabled"]) : toset([])
    content {
      log_analytics_workspace_id      = azurerm_log_analytics_workspace.main[0].id
      msi_auth_for_monitoring_enabled = true
    }
  }

  default_node_pool {
    name                        = var.node_groups.default_node_group.name
    vm_size                     = var.node_groups.default_node_group.node_size
    min_count                   = var.node_groups.default_node_group.min_size
    max_count                   = var.node_groups.default_node_group.max_size
    vnet_subnet_id              = var.vnet.data.infrastructure.default_subnet_id
    temporary_name_for_rotation = "${random_string.temp_node_group.result}temp"
    auto_scaling_enabled        = true
    upgrade_settings {
      max_surge = "10%"
    }
    tags = var.md_metadata.default_tags
  }

  identity {
    type = "SystemAssigned"
  }

  /* These are hardcoded so they cannot possibly conflict with anything that
  the customer might set as their VNet CIDR. These are also the defaults for
  these parameters when deploying AKS in the Azure Portal. */
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "172.20.0.10"
    service_cidr      = "172.20.0.0/16"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }


}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = { for ng in var.node_groups.additional_node_groups : ng.name => ng }
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.node_size
  vnet_subnet_id        = var.vnet.data.infrastructure.default_subnet_id
  auto_scaling_enabled  = true
  mode                  = "User"
  max_count             = each.value.max_size
  min_count             = each.value.min_size
  node_taints           = each.value.compute_type == "GPU" ? ["sku=gpu:NoSchedule"] : []
  upgrade_settings {
    max_surge = "10%"
  }
  tags = var.md_metadata.default_tags
}

data "azurerm_client_config" "main" {
}

resource "azurerm_role_assignment" "aks_read_acr" {
  scope                = "/subscriptions/${data.azurerm_client_config.main.subscription_id}"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Network Contributor role for AKS cluster identity to manage load balancers and network resources
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.vnet.data.infrastructure.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
