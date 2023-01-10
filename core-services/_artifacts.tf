locals {
  data_authentication = {
    cluster = {
      server                     = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
      certificate-authority-data = data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
    }
    user = {
      token = lookup(data.kubernetes_secret.massdriver-cloud-provisioner_service-account_secret.data, "token")
    }
  }
  data_infrastructure = {
    ari = data.azurerm_kubernetes_cluster.cluster.id
    # As of Jan 10th this is still in preview.
    # https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview
    # https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview#install-the-aks-preview-azure-cli-extension
    # az extension add --name aks-preview
    # az extension update --name aks-preview
    # az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
    # No location, resource group, etc...
    # There's no way I've found to turn that on in TF outside of a null_resource but it looks global and it's idempotent
    oidc_issuer_url = data.azurerm_kubernetes_cluster.cluster.oidc_issuer_url
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
