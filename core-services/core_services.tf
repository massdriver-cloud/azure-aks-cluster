locals {
  enable_azure_dns    = var.core_services.enable_ingress ? 1 : 0
  zone_split_id       = local.enable_azure_dns ? split("/", var.core_services.azure_dns_zone) : []
  dns_zone_names      = local.enable_azure_dns ? element(local.zone_split_id, index(local.zone_split_id, "dnszones") + 1) : null
  dns_resource_group  = local.enable_azure_dns ? element(local.zone_split_id, index(local.zone_split_id, "resourceGroups") + 1) : null
  enable_cert_manager = length(local.dns_zone_names) > 0 && length(local.dns_resource_group) > 0
  enable_external_dns = length(local.dns_zone_names) > 0 && length(local.dns_resource_group) > 0
}

resource "kubernetes_namespace" "md-core-services" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-core-services"
  }
}

module "ingress_nginx" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-ingress-nginx?ref=3e6071e"
  count              = var.core_services.enable_ingress ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "ingress-nginx"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
}

module "external_dns" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-external-dns-azure?ref=3e6071e"
  count              = local.enable_external_dns ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "external-dns"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
  azure_dns_zone     = var.core_services.azure_dns_zone
}

module "cert_manager" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-cert-manager-azure?ref=3e6071e"
  count              = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "cert-manager"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
}
