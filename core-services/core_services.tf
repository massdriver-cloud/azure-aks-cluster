locals {
  dns_zones           = try(var.core_services.azure_dns_zones, [])
  enable_cert_manager = length(local.dns_zones) > 0
  enable_external_dns = length(local.dns_zones) > 0

  zones_with_resource_group = [
    for zone_id in local.dns_zones : {
      name           = element(split("/", zone_id), index(split("/", zone_id), "dnszones") + 1)
      resource_group = element(split("/", zone_id), index(split("/", zone_id), "resourceGroups") + 1)
    }
  ]
}

resource "kubernetes_namespace_v1" "md-core-services" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-core-services"
  }
}

module "ingress_nginx" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-ingress-nginx?ref=cf5cadd"
  count              = var.core_services.enable_ingress ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "ingress-nginx"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name
}

module "external_dns" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-external-dns-azure?ref=cf5cadd"
  count              = local.enable_external_dns ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "external-dns"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name
  # This is hard-coded to one zone for now.
  # We might be able to for_each this module and call it good but we have to come back to this.
  # https://github.com/massdriver-cloud/azure-aks-cluster/issues/34
  azure_dns_zones = {
    dns_zones      = [local.zones_with_resource_group[0].name]
    resource_group = local.zones_with_resource_group[0].resource_group
  }
}

module "cert_manager" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-cert-manager-azure?ref=cf5cadd"
  count              = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "cert-manager"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name
}
