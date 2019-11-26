resource "kubernetes_role" "kfp_sdk_user_role" {
  depends_on = ["kubernetes_namespace.kubeflow"]

  metadata {
    name      = "kfp-sdk-user"
    namespace = "kubeflow"
    labels = {
      app = "ml-pipeline"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services/proxy"]
    verbs      = ["create", "get", "list"]
  }
}

resource "kubernetes_role_binding" "kfp_sdk_user_rolebinding" {
  depends_on = ["kubernetes_role.kfp_sdk_user_role"]

  metadata {
    name      = "kfp-sdk-user"
    namespace = "kubeflow"
    labels = {
      app = "ml-pipeline"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kfp-sdk-user"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:authenticated"
    namespace = "kubeflow"
  }
}
