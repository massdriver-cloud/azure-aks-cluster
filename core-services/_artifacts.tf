locals {
  data_authentication = {
    cluster = {
      server                     = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
      certificate-authority-data = data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
    }
    user = {
      token = lookup(kubernetes_secret_v1.massdriver-cloud-provisioner_token.data, "token")
    }
  }
  data_infrastructure = {
    ari = data.azurerm_kubernetes_cluster.cluster.id
    # Add this back in after the its out of preview
    # oidc_issuer_url = data.azurerm_kubernetes_cluster.cluster.oidc_issuer_url
  }
  specs_kubernetes = {
    cloud            = "azure"
    distribution     = "aks"
    version          = data.azurerm_kubernetes_cluster.cluster.kubernetes_version
    platform_version = ""
  }

  kubernetes_cluster_artifact = {
    data = {
      infrastructure = local.data_infrastructure
      authentication = local.data_authentication
    }
    specs = {
      kubernetes = local.specs_kubernetes
    }
  }
}

resource "massdriver_artifact" "kubernetes_cluster" {
  field                = "kubernetes_cluster"
  provider_resource_id = data.azurerm_kubernetes_cluster.cluster.id
  name                 = "AKS Cluster Credentials ${data.azurerm_kubernetes_cluster.cluster.name} [${var.vnet.specs.azure.region}]"
  artifact             = jsonencode(local.kubernetes_cluster_artifact)
}
