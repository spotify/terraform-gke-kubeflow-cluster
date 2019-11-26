# this is taken from https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/d8e78504c51b194ce30e736f7a3a4240b9dbcd9d/dns.tf
# but modified to set baseMemory for metrics-server-config

/******************************************
  Delete default metrics-server-config configmap
 *****************************************/
resource "null_resource" "delete_metrics_server_config_configmap" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/kubectl_wrapper.sh https://${local.cluster_endpoint} ${data.google_client_config.default.access_token} ${local.cluster_ca_certificate} ${path.module}/scripts/delete-default-resource.sh kube-system configmap metrics-server-config"
  }

  depends_on = [
    "data.google_client_config.default",
    "google_container_cluster.kubeflow_cluster",
  ]
}


/******************************************
  Update metrics-server-config configmap
 *****************************************/
resource "kubernetes_config_map" "metrics-server-config" {
  metadata {
    name      = "metrics-server-config"
    namespace = "kube-system"
  }

  data = {
    # currently we only set baseMemory, but more resources can be tuned if necessary
    # https://github.com/kubernetes/autoscaler/tree/master/addon-resizer#edit-a-configuration
    NannyConfiguration = chomp(<<EOF
apiVersion: nannyconfig/v1alpha1
kind: NannyConfiguration
baseMemory: 400Mi
EOF
  ) }

  depends_on = [
    "null_resource.delete_metrics_server_config_configmap",
    "google_container_cluster.kubeflow_cluster",
  ]
}
