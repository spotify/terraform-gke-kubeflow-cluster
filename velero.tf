# Setup for Velero for backing up cluster state
# https://velero.io/docs/v1.0.0/gcp-config/
#
# Creates:
# - one GCS bucket
# - one GCP Service Account
# - necessary IAM bindings for the SA to write/read to the bucket
# - k8s namespace for Velero
# - k8s secret for Velero to use the GCP SA
# These resources are per module instance, so we get one per cluster.

locals {
  namespace = "velero"
}

# Create a unique GCS bucket per cluster
resource "google_storage_bucket" "backup_bucket" {
  name = "${var.project}_${var.cluster_region}_${var.cluster_name}_backup"

  bucket_policy_only = true

  location = "EU"

  # don't destroy buckets containing backup data if re-creating a cluster
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "velero" {
  project      = "${var.project}"
  account_id   = "${var.cluster_name}-velero"
  display_name = "Velero account for ${var.cluster_name}"
}

resource "google_service_account_key" "velero" {
  service_account_id = "${google_service_account.velero.name}"
}

resource "google_storage_bucket_iam_binding" "ark_bucket_iam" {
  bucket = "${google_storage_bucket.backup_bucket.name}"
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.velero.email}"
  ]

  # don't destroy buckets containing backup data if re-creating a cluster
  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "${local.namespace}"
    labels = {
      "component" = "velero"
    }
  }
}

resource "kubernetes_secret" "service_account_key" {
  depends_on = ["kubernetes_namespace.velero"]

  metadata {
    namespace = "${local.namespace}"
    name      = "cloud-credentials"
    labels = {
      "component" = "velero"
    }
  }

  data = {
    "cloud" = "${base64decode(google_service_account_key.velero.private_key)}"
  }
}
