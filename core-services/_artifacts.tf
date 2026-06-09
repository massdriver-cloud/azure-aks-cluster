locals {
  authentication = {
    cluster = {
      server                     = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
      certificate-authority-data = data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
    }
    user = {
      token = lookup(kubernetes_secret_v1.massdriver_access_token.data, "token")
    }
  }
  infrastructure = {
    ari             = data.azurerm_kubernetes_cluster.cluster.id
    oidc_issuer_url = data.azurerm_kubernetes_cluster.cluster.oidc_issuer_url
  }
  specs_kubernetes = {
    cloud            = "azure"
    distribution     = "aks"
    version          = data.azurerm_kubernetes_cluster.cluster.kubernetes_version
    platform_version = ""
  }
  specs_azure = {
    region = data.azurerm_kubernetes_cluster.cluster.location
  }
  kubernetes_cluster_artifact = {
    infrastructure = local.infrastructure
    authentication = local.authentication
    specs = {
      kubernetes = local.specs_kubernetes
      azure      = local.specs_azure
    }
  }
}

resource "massdriver_artifact" "kubernetes_cluster" {
  field    = "kubernetes_cluster"
  name     = "AKS Cluster Credentials ${data.azurerm_kubernetes_cluster.cluster.name} [${var.vnet.specs.azure.region}]"
  artifact = jsonencode(local.kubernetes_cluster_artifact)
}
