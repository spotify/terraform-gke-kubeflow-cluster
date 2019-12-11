# Allows other resources to refer to things like the authorization token for
# the configured Google account
data "google_client_config" "default" {}

# The GKE cluster. The node pool is managed as a separate resource below.
resource "google_container_cluster" "kubeflow_cluster" {
  depends_on = [
    "google_service_account.kubeflow_admin",
    "google_service_account.kubeflow_user",
    "google_service_account.kubeflow_vm",
  ]

  provider = "google-beta"

  name     = "${var.cluster_name}"
  location = "${var.cluster_zone}"
  project  = "${var.project}"

  # TPU requires a separate ip range (https://cloud.google.com/tpu/docs/kubernetes-engine-setup)
  # Disable it for now until we figure out how it works with xpn network
  enable_tpu = false

  min_master_version = "${var.min_master_version}"

  network    = "${var.network}"
  subnetwork = "${var.subnetwork}"

  # https://www.terraform.io/docs/providers/google/r/container_cluster.html
  # recommends managing the node pool as a separate resource, which we do
  # below.
  remove_default_node_pool = true
  initial_node_count       = "1"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.cluster_secondary_range_name}"
    services_secondary_range_name = "${var.services_secondary_range_name}"
  }

  resource_labels = {
    "application" = "kubeflow"
    "env"         = "${var.env_label}"
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = true
    }

    network_policy_config {
      disabled = "${var.network_policy_enabled == false ? true : false}"
    }

  }

  enable_legacy_abac = false

  master_auth {
    client_certificate_config {
      issue_client_certificate = "${var.issue_client_certificate}"
    }

    # Setting an empty username disables basic auth
    # From https://cloud.google.com/sdk/gcloud/reference/container/clusters/create:
    # --no-enable-basic-auth is an alias for --username=""
    username = ""

    # password is required if username is present
    password = ""
  }

  network_policy {
    enabled  = "${var.network_policy_enabled}"
    provider = "${var.network_policy_enabled == true ? "CALICO" : null}"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  timeouts {
    create = "${var.timeout}"
    update = "${var.timeout}"
    delete = "${var.timeout}"
  }

  # node auto-provisioning, they screwed up the name of fields here
  # https://github.com/terraform-providers/terraform-provider-google/issues/3303#issuecomment-477251119
  cluster_autoscaling {
    enabled = false
  }
}

resource "google_container_node_pool" "main_pool" {
  # max_pods_per_node is in google-beta as of 2019-07-26
  provider = "google-beta"

  cluster  = "${google_container_cluster.kubeflow_cluster.name}"
  location = "${var.cluster_zone}"
  project  = "${var.project}"

  name = "${var.main_node_pool_name}"

  version            = "${var.node_version}"
  initial_node_count = "${var.initial_node_count}"

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }

  autoscaling {
    min_node_count = "${var.main_node_pool_min_nodes}"
    max_node_count = "${var.main_node_pool_max_nodes}"
  }

  max_pods_per_node = "${var.max_pods_per_node}"

  node_config {
    machine_type = "${var.main_node_pool_machine_type}"

    min_cpu_platform = "Intel Broadwell"

    service_account = "${google_service_account.kubeflow_vm.email}"

    // These scopes are needed for the GKE nodes' service account to have pull rights to GCR.
    // Default is "https://www.googleapis.com/auth/logging.write" and "https://www.googleapis.com/auth/monitoring".
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  timeouts {
    create = "${var.timeout}"
    update = "${var.timeout}"
    delete = "${var.timeout}"
  }
}

resource "google_container_node_pool" "gpu_pool" {
  # max_pods_per_node is in google-beta as of 2019-07-26
  provider = "google-beta"

  cluster  = "${google_container_cluster.kubeflow_cluster.name}"
  location = "${var.cluster_zone}"
  project  = "${var.project}"

  name = "${var.gpu_node_pool_name}"

  version            = "${var.node_version}"
  initial_node_count = "0"

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }

  autoscaling {
    min_node_count = "0"
    max_node_count = "10"
  }

  max_pods_per_node = "${var.max_pods_per_node}"

  node_config {
    machine_type = "${var.gpu_node_pool_machine_type}"

    guest_accelerator {
      type  = "nvidia-tesla-k80"
      count = 1
    }

    min_cpu_platform = "Intel Broadwell"

    service_account = "${google_service_account.kubeflow_vm.email}"

    // These scopes are needed for the GKE nodes' service account to have pull rights to GCR.
    // Default is "https://www.googleapis.com/auth/logging.write" and "https://www.googleapis.com/auth/monitoring".
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  timeouts {
    create = "${var.timeout}"
    update = "${var.timeout}"
    delete = "${var.timeout}"
  }
}

resource "google_container_node_pool" "highmem_pool" {
  # max_pods_per_node is using the default value defined in google-beta api
  provider = "google-beta"

  cluster  = "${google_container_cluster.kubeflow_cluster.name}"
  location = "${var.cluster_zone}"
  project  = "${var.project}"

  name = "${var.highmem_node_pool_name}"

  version            = "${var.node_version}"
  initial_node_count = "0"

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }

  autoscaling {
    min_node_count = "0"
    max_node_count = "10"
  }

  max_pods_per_node = "${var.max_pods_per_node}"

  node_config {
    machine_type = "${var.highmem_node_pool_machine_type}"

    min_cpu_platform = "Intel Broadwell"

    service_account = "${google_service_account.kubeflow_vm.email}"

    // These scopes are needed for the GKE nodes' service account to have pull rights to GCR.
    // Default is "https://www.googleapis.com/auth/logging.write" and "https://www.googleapis.com/auth/monitoring".
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  timeouts {
    create = "${var.timeout}"
    update = "${var.timeout}"
    delete = "${var.timeout}"
  }
}

# A persistent disk to use as the artifact store.
resource "google_compute_disk" "artifact_store" {
  name                      = "${var.cluster_name}-artifact-store"
  zone                      = "${var.cluster_zone}"
  project                   = "${var.project}"
  physical_block_size_bytes = 4096
  size                      = 200
  labels = {
    "application"              = "kubeflow"
    "env"                      = "${var.env_label}"
    "cloudsql-instance-suffix" = "${random_id.db_name_suffix.hex}"
    # This label will be automatically created when the disk is attached to a GKE instance.
    # We include it here to prevent Terraform deleting it.
    "goog-gke-volume" = ""
  }
}

resource "google_compute_resource_policy" "artifact_store-snapshot-schedule" {
  name     = "${google_compute_disk.artifact_store.name}-snapshot-schedule"
  provider = "google-beta"
  project  = "${var.project}"
  region   = "${var.cluster_region}"

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "04:00"
      }
    }

    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }

    snapshot_properties {
      labels = {
        "application"              = "kubeflow"
        "env"                      = "${var.env_label}"
        "cloudsql-instance-suffix" = "${random_id.db_name_suffix.hex}"
      }
    }
  }
}
