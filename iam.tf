resource "google_service_account" "cloudsql_proxy" {
  project      = "${var.project}"
  account_id   = "${var.cluster_name}-cloudsqlproxy-sa"
  display_name = "Service account for ${var.cluster_name} to connect to cloudsql"
}

resource "google_service_account" "kubeflow_user" {
  project      = "${var.project}"
  account_id   = "${var.cluster_name}-user-sa"
  display_name = "User account for ${var.cluster_name}"
}

resource "google_service_account" "kubeflow_vm" {
  project      = "${var.project}"
  account_id   = "${var.cluster_name}-vm-sa"
  display_name = "VM (GKE node) service account for ${var.cluster_name}"
}

resource "google_service_account" "kubeflow_admin" {
  project      = "${var.project}"
  account_id   = "${var.cluster_name}-admin-sa"
  display_name = "Admin account for ${var.cluster_name}"
}

resource "google_project_iam_member" "kubeflow_admin-source_admin" {
  project = "${var.project}"
  role    = "roles/source.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_admin.email}"
}

resource "google_project_iam_member" "kubeflow_admin-servicemanagement-admin" {
  project = "${var.project}"
  role    = "roles/servicemanagement.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_admin.email}"
}

resource "google_project_iam_member" "kubeflow_admin-compute_networkadmin" {
  project = "${var.project}"
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.kubeflow_admin.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-cloudbuild_builds_editor" {
  project = "${var.project}"
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-viewer" {
  project = "${var.project}"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-source_admin" {
  project = "${var.project}"
  role    = "roles/source.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-storage_admin" {
  project = "${var.project}"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-bigquery_admin" {
  project = "${var.project}"
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-dataflow_admin" {
  project = "${var.project}"
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-ml_admin" {
  project = "${var.project}"
  role    = "roles/ml.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-dataproc_editor" {
  project = "${var.project}"
  role    = "roles/dataproc.editor"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_user-compute-cloudsql_admin" {
  project = "${var.project}"
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.kubeflow_user.email}"
}

resource "google_project_iam_member" "kubeflow_vm-compute-logging_logwriter" {
  project = "${var.project}"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.kubeflow_vm.email}"
}

resource "google_project_iam_member" "kubeflow_vm-compute-monitoring_metricwriter" {
  project = "${var.project}"
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.kubeflow_vm.email}"
}

resource "google_project_iam_member" "kubeflow_vm-compute-storage_objectviewer" {
  project = "${var.project}"
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.kubeflow_vm.email}"
}

resource "google_project_iam_member" "cloudsql_proxy-cloudsql_admin" {
  project = "${var.project}"
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

resource "google_project_iam_member" "cloudsql_proxy-cloudsql_editor" {
  project = "${var.project}"
  role    = "roles/cloudsql.editor"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

resource "google_project_iam_member" "cloudsql_proxy-cloudsql_client" {
  project = "${var.project}"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

resource "google_service_account_key" "cloudsql_proxy_key" {
  service_account_id = "${google_service_account.cloudsql_proxy.name}"
}

resource "google_service_account_key" "kubeflow_admin_key" {
  service_account_id = "${google_service_account.kubeflow_admin.name}"
}

resource "google_service_account_key" "kubeflow_user_key" {
  service_account_id = "${google_service_account.kubeflow_user.name}"
}
