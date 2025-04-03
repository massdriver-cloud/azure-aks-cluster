locals {
  alarms = {
    unscheduled_pods_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThanOrEqual"
      aggregation = "Average"
      threshold   = 1
    }
  }
}

module "alarm_channel" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//k8s/alarm-channel?ref=42d293b"
  md_metadata = var.md_metadata
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name
  release     = var.md_metadata.name_prefix

  depends_on = [module.prometheus-observability]
}

module "azure_alarm_channel" {
  count               = true ? 1 : 0
  source              = "github.com/massdriver-cloud/terraform-modules//azure/alarm-channel?ref=42d293b"
  md_metadata         = var.md_metadata
  resource_group_name = data.azurerm_resource_group.cluster.name
}

module "application_alarms" {
  count             = true ? 1 : 0
  source            = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-application-alarms?ref=42d293b"
  md_metadata       = var.md_metadata
  pod_alarms        = true
  deployment_alarms = true
  daemonset_alarms  = true

  depends_on = [module.prometheus-observability]
}

module "unscheduled_pods_metric_alert" {
  count                   = true ? 1 : 0
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=42d293b"
  scopes                  = [data.azurerm_kubernetes_cluster.cluster.id]
  resource_group_name     = data.azurerm_resource_group.cluster.name
  monitor_action_group_id = module.azure_alarm_channel.0.id
  severity                = local.alarms.unscheduled_pods_metric_alert.severity
  frequency               = local.alarms.unscheduled_pods_metric_alert.frequency
  window_size             = local.alarms.unscheduled_pods_metric_alert.window_size

  depends_on = [
    module.prometheus-observability
  ]

  md_metadata  = var.md_metadata
  display_name = "Autoscaler Unscheduled Pods"
  message      = "Autoscaler Unscheduled Pod Detected"

  alarm_name       = "${var.md_metadata.name_prefix}-autoscalerUnscheduledPod"
  operator         = local.alarms.unscheduled_pods_metric_alert.operator
  metric_name      = "cluster_autoscaler_unschedulable_pods_count"
  metric_namespace = "microsoft.containerservice/managedclusters"
  aggregation      = local.alarms.unscheduled_pods_metric_alert.aggregation
  threshold        = local.alarms.unscheduled_pods_metric_alert.threshold
}
