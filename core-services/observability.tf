resource "kubernetes_namespace" "md-observability" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-observability"
  }
}

module "kube-state-metrics" {
  source      = "github.com/massdriver-cloud/terraform-modules//kube-state-metrics?ref=54da4ef"
  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = kubernetes_namespace.md-observability.metadata.0.name
}
