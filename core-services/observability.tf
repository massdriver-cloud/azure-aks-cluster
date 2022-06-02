resource "kubernetes_namespace" "md-observability" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-observability"
  }
}

module "kube-state-metrics" {
  source = "../../../provisioners/terraform/modules/k8s-kube-state-metrics"
  count  = true ? 1 : 0

  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = kubernetes_namespace.md-observability.metadata.0.name
}
