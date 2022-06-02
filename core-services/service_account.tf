resource "kubernetes_service_account" "massdriver-cloud-provisioner" {
  metadata {
    name   = "massdriver-cloud-provisioner"
    labels = var.md_metadata.default_tags
  }
}

resource "kubernetes_cluster_role_binding" "massdriver-cloud-provisioner" {
  metadata {
    name   = "massdriver-cloud-provisioner"
    labels = var.md_metadata.default_tags
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.massdriver-cloud-provisioner.metadata.0.name
    namespace = kubernetes_service_account.massdriver-cloud-provisioner.metadata.0.namespace
  }
}

data "kubernetes_secret" "massdriver-cloud-provisioner_service-account_secret" {
  metadata {
    name   = kubernetes_service_account.massdriver-cloud-provisioner.default_secret_name
    labels = var.md_metadata.default_tags
  }
}
