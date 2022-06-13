locals {
  dns_zones           = try(var.core_services.azure_dns_zones.dns_zones, [])
  dns_resource_group  = try(var.core_services.azure_dns_zones.resource_group, "")
  enable_cert_manager = length(local.dns_zones) > 0 && length(local.dns_resource_group) > 0
  enable_external_dns = length(local.dns_zones) > 0 && length(local.dns_resource_group) > 0
}

resource "kubernetes_namespace" "md-core-services" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-core-services"
  }
}

module "ingress_nginx" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-ingress-nginx?ref=54da4ef"
  count              = var.core_services.enable_ingress ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "ingress-nginx"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
}

module "external_dns" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-external-dns-azure?ref=54da4ef"
  count              = local.enable_external_dns ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "external-dns"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
  azure_dns_zones    = var.core_services.azure_dns_zones
}

module "cert_manager" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-cert-manager-azure?ref=54da4ef"
  count              = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "cert-manager"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
}
