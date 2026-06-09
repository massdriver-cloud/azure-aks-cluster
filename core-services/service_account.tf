resource "kubernetes_service_account_v1" "massdriver_access" {
  metadata {
    name      = "massdriver-access"
    namespace = "kube-system"
    labels    = var.md_metadata.default_tags
  }
  automount_service_account_token = false
}

resource "kubernetes_cluster_role_binding_v1" "massdriver_access" {
  metadata {
    name   = "massdriver-access"
    labels = var.md_metadata.default_tags
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.massdriver_access.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "massdriver_access_token" {
  metadata {
    name      = "massdriver-access-token"
    namespace = "kube-system"
    labels    = var.md_metadata.default_tags
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.massdriver_access.metadata.0.name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
