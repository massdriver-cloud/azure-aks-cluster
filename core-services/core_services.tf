locals {
  enable_azure_dns = length(var.core_services.azure_dns_zones) > 0
  split_zone_id    = split("/", var.core_services.azure_dns_zones.dns_zone[0])
  azure_dns_zones = local.enable_azure_dns ? { # This is hardcoded to expect a single element. Will need to change this when multiple DNS zones are supported by external DNS.
    dns_zones      = toset([element(split("/", local.split_zone_id), index(split("/", local.split_zone_id), "dnszones") + 1)])
    resource_group = element(split("/", local.split_zone_id), index(split("/", local.split_zone_id), "resourceGroups") + 1)
  } : null
  enable_cert_manager = local.enable_azure_dns
  enable_external_dns = local.enable_azure_dns
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
  azure_dns_zones    = local.azure_dns_zones
}

module "cert_manager" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-cert-manager-azure?ref=3e6071e"
  count              = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "cert-manager"
  namespace          = kubernetes_namespace.md-core-services.metadata.0.name
}
