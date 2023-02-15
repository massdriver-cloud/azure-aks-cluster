locals {
  machine_types = join("", var.node_groups.default_node_group[*].node_size, var.node_groups.additional_node_groups[*].node_size)
  # https://learn.microsoft.com/en-us/azure/virtual-machines/nc-a100-v4-series
  install_nvidia_driver = length(regexall("_A100_v4", local.machine_types)) > 0
}

# https://learn.microsoft.com/en-us/azure/aks/gpu-cluster#manually-install-the-nvidia-device-plugin
resource "kubernetes_daemonset" "nvidia_driver" {
  count = local.install_nvidia_driver ? 1 : 0
  metadata {
    name      = "nvidia-device-plugin-daemonset"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        name = "nvidia-device-plugin-ds"
      }
    }

    template {
      metadata {
        # Mark this pod as a critical add-on; when enabled, the critical add-on scheduler
        # reserves resources for critical add-on pods so that they can be rescheduled after
        # a failure.  This annotation works in tandem with the toleration below.
        annotations = {
          "scheduler.alpha.kubernetes.io/critical-pod" = ""
        }
        labels = {
          name = "nvidia-device-plugin-ds"
        }
      }

      spec {
        # Allow this pod to be rescheduled while the node is in "critical add-ons only" mode.
        # This, along with the annotation above marks this pod as a critical add-on.
        toleration {
          operator = "Exists"
          key      = "CriticalAddonsOnly"
        }

        toleration {
          operator = "Exists"
          key      = "nvidia.com/gpu"
          effect   = "NoSchedule"
        }

        toleration {
          operator = "Equal"
          key      = "sku"
          value    = "gpu"
          effect   = "NoSchedule"
        }

        volume {
          name = "device-plugin"
          host_path {
            path = "/var/lib/kubelet/device-plugins"
          }
        }

        container {
          image = "mcr.microsoft.com/oss/nvidia/k8s-device-plugin:1.11"
          name  = "nvidia-device-plugin-ctr"

          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "device-plugin"
            mount_path = "/var/lib/kubelet/device-plugins"
          }
        }

      }
    }
  }
}

