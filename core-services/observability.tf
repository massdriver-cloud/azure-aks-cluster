resource "kubernetes_namespace_v1" "md-observability" {
  metadata {
    labels = var.md_metadata.default_tags
    name   = "md-observability"
  }
}

module "prometheus-observability" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-prometheus-observability?ref=42d293b"
  md_metadata = var.md_metadata
  release     = "massdriver"
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name
  helm_additional_values = {
    grafana = {
      enabled       = lookup(var.monitoring.prometheus, "grafana_enabled", false)
      adminPassword = lookup(var.monitoring.prometheus, "grafana_password", "prom-operator")
    }
  }
}

module "prometheus-rules" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-prometheus-rules?ref=42d293b"
  md_metadata = var.md_metadata
  release     = "massdriver"
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name

  depends_on = [module.prometheus-observability]
}
