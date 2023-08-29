resource "kubernetes_namespace_v1" "md-observability" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-observability"
  }
}

module "prometheus-observability" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-prometheus-observability?ref=41e799c"
  md_metadata = var.md_metadata
  release     = "massdriver"
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name
}

module "prometheus-rules" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-prometheus-rules?ref=41e799c"
  md_metadata = var.md_metadata
  release     = "massdriver"
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name

  depends_on = [module.prometheus-observability]
}
