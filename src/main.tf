locals {
  size_map = {
    "B2s (2 vCores, 4 GiB memory)"     = "B2s"
    "B2ms (2 vCores, 8 GiB memory)"    = "B2ms"
    "B4ms (4vCores, 16 GiB memory)"    = "B4ms"
    "B8ms (8 vCores, 32 GiB memory)"   = "B8ms"
    "B16ms (16 vCores, 64 GiB memory)" = "B16ms"
    "DS2 (2 vCores, 7 GiB memory)"     = "DS2_v2"
    "DS3 (4 vCores, 14 GiB memory)"    = "DS3_v2"
    "D2s (2 vCores, 8 GiB memory)"     = "D2s_v3"
    "D4s (4 vCores, 16 GiB memory)"    = "D4s_v3"
    "D8s (8 vCores, 32 GiB memory)"    = "D8s_v3"
    "D16s (16 vCores, 64 GiB memory)"  = "D16s_v3"
    "D32s (32 vCores, 64 GiB memory)"  = "D32s_v3"
    "D64s (64 vCores, 256 GiB memory)" = "D64s_v3"
    "E2s (2 vCores, 16 GiB memory)"    = "E2s_v3"
    "E4s (4 vCores, 32 GiB memory)"    = "E4s_v3"
    "E8s (8 vCores, 64 GiB memory)"    = "E8s_v3"
    "E16s (8 vCores, 128 GiB memory)"  = "E16s_v3"
    "E32s (32 vCores, 256 GiB memory)" = "E32s_v3"
    "E64s (64 vCores, 432 GiB memory)" = "E64s_v3"
    "F2s (2 vCores, 4 GiB memory)"     = "F2s_v2"
    "F4s (4 vCores, 8 GiB memory)"     = "F4s_v2"
    "F8s (8 vCores, 16 GiB memory)"    = "F8s_v2"
    "F16s (16 vCores, 32 GiB memory)"  = "F16s_v2"
    "F32s (32 vCores, 64 GiB memory)"  = "F32s_v2"
    "F64s (64 vCores, 128 GiB memory)" = "F64s_v2"
  }

  family = "Standard"

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
    vm_size        = "${local.family}_${local.size_map[var.node_groups[0].node_size]}"
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
  vm_size               = "${local.family}_${local.size_map[each.value.node_size]}"
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
