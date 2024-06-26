resource "kubernetes_daemonset" "nvidia" {
  count = try(var.node_groups.additional_node_groups.0.compute_type == "GPU" ? 1 : 0, 0)
  metadata {
    name      = "nvidia-device-plugin-daemonset"
    namespace = kubernetes_namespace_v1.md-core-services.metadata.0.name
    labels = merge(var.md_metadata.default_tags, {
      k8s-app = "nvidia-device-plugin-daemonset"
    })
  }
  spec {
    selector {
      match_labels = {
        name = "nvidia-device-plugin-ds"
      }
    }
    strategy {
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = merge(var.md_metadata.default_tags, {
          name = "nvidia-device-plugin-ds"
        })
        annotations = {
          "scheduler.alpha.kubernetes.io/critical-pod" : ""
        }
      }
      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "accelerator"
                  operator = "In"
                  values   = ["nvidia"]
                }
              }
            }
          }
        }
        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
        toleration {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        toleration {
          key      = "sku"
          operator = "Equal"
          value    = "gpu"
          effect   = "NoSchedule"
        }
        container {
          name  = "nvidia-device-plugin-ctr"
          image = "mcr.microsoft.com/oss/nvidia/k8s-device-plugin:v0.14.1"
          security_context {
            privileged = true
            capabilities {
              drop = ["ALL"]
            }
          }
          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }
        }
        volume {
          name = "device-plugin"
          host_path {
            path = "/var/lib/kubelet/device-plugins"
          }
        }
      }
    }
  }
}
