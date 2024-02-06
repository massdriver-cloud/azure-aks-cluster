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

  azure_dns_zones_map = {
    for zone_id in local.dns_zones : element(split("/", zone_id), index(split("/", zone_id), "dnszones") + 1) => {
      resource_group = element(split("/", zone_id), index(split("/", zone_id), "resourceGroups") + 1)
    }
  }
}

resource "kubernetes_namespace_v1" "md-core-services" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-core-services"
  }
}

module "ingress_nginx" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-ingress-nginx?ref=b4c1dda"
  count              = var.core_services.enable_ingress ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "ingress-nginx"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name
  helm_additional_values = {
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/healthz"
        }
        externalTrafficPolicy = "Local"
      }
    }
    metrics = {
      enabled = true
      serviceMonitor = {
        enabled = true
      }
    }
  }

  depends_on = [module.prometheus-observability]
}

module "external_dns" {
  for_each           = local.azure_dns_zones_map
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-external-dns-azure?ref=b4c1dda"
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "external-dns"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name

  azure_dns_zones = {
    dns_zones      = [each.key]
    resource_group = each.value.resource_group
  }

  depends_on = [module.prometheus-observability]
}

module "cert_manager" {
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-cert-manager-azure?ref=b4c1dda"
  count              = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "cert-manager"
  namespace          = kubernetes_namespace_v1.md-core-services.metadata.0.name

  depends_on = [module.prometheus-observability]
}
