resource "kubernetes_namespace" "md-observability" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-observability"
  }
}

module "kube-state-metrics" {
  source = "github.com/massdriver-cloud/terraform-modules//k8s-kube-state-metrics?ref=54da4ef"
  count  = true ? 1 : 0

  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = kubernetes_namespace.md-observability.metadata.0.name
}

module "opensearch" {
  count       = var.observability.logging.destination == "opensearch" ? 1 : 0
  # TODO replace ref with a SHA once k8s-opensearch is merged
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=opensearch"
  md_metadata = var.md_metadata
  release     = "opensearch"
  namespace   = "md-observability" # TODO should this be monitoring?
  kubernetes_cluster =  local.kubernetes_cluster_artifact
  helm_additional_values = {
    persistence = {
        size = var.observability.logging.opensearch.persistence_size
    }
  } 
  enable_dashboards = var.observability.logging.opensearch.enable_dashboards
  // this adds a retention policy to move indexes to warm after 1 day and delete them after a user configurable number of days
  ism_policies = {
    "hot-warm-delete": templatefile("${path.module}/logging/opensearch/ism_hot_warm_delete.json.tftpl", {"log_retention_days": var.observability.logging.opensearch.retention_days})
  }
}
