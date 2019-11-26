variable "project" {
  description = "GCP project to create the resources in"
}

variable "env_label" {
  description = "Environment label: test, dev, prod"
}

variable "cluster_name" {
  description = "Name of the GKE cluster, will also be used as a part of the name for related resources like Cloud SQL instance and persistent disk."
}

# cluster region is needed for cloudsql instance and artifact store disc snapshot
variable "cluster_region" {
  description = "The region of the cluster and is also used for Cloud SQL instance and artifact store Persistent Disk snapshot."
}

# TODO: support for a regional cluster? https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters
variable "cluster_zone" {
  description = "The location of the cluster - can be a zone or region name. Set to zone name for zonal clusters, region name for regional clusters."
}

variable "min_master_version" {
  description = "Minimum version of Kubernetes to install on master (optional), see https://www.terraform.io/docs/providers/google/r/container_cluster.html#min_master_version"
  default     = ""
}

variable "node_version" {
  description = "(optional) https://www.terraform.io/docs/providers/google/r/container_cluster.html#node_version"
  default     = ""
}

variable "network" {
  description = "Set this to the network of another project (along with subnetwork, cluster_secondary_range_name, and services_secondary_range_name, to enable Shared VPC. Set to network of project for non-Shared VPC. https://www.terraform.io/docs/providers/google/r/container_cluster.html#network"
}

variable "subnetwork" {
  description = "https://www.terraform.io/docs/providers/google/r/container_cluster.html#subnetwork"
}

variable "cluster_secondary_range_name" {
  description = "Only set for Shared VPC clusters. https://www.terraform.io/docs/providers/google/r/container_cluster.html#cluster_secondary_range_name"
  # default to not Shared VPC
  default = ""
}

variable "services_secondary_range_name" {
  description = "Only set for Shared VPC clusters. https://www.terraform.io/docs/providers/google/r/container_cluster.html#services_ipv4_cidr_block"
  # default to not Shared VPC
  default = ""
}

variable "initial_node_count" {
  default = 3
}

variable "main_node_pool_min_nodes" {
  description = "Value to set for min node count for cluster autoscaler for the main node pool."
}

variable "main_node_pool_max_nodes" {
  description = "Value to set for max node count for cluster autoscaler for the main node pool."
}

variable "max_pods_per_node" {
  description = "Sets the default_max_pods_per_node setting on the container_cluster resource."
  default     = 110
}

variable "auto_repair" {
  default = "true"
}

variable "auto_upgrade" {
  default = "false"
}

variable "main_node_pool_machine_type" {
  default = "n1-standard-8"
}

variable "gpu_node_pool_machine_type" {
  default = "n1-standard-8"
}

variable "highmem_node_pool_machine_type" {
  default = "n2-highmem-16"
}

variable "issue_client_certificate" {
  description = "Ideally this should always be set to false, this feature is going away eventually. https://www.terraform.io/docs/providers/google/r/container_cluster.html#client_certificate_config"
  default     = false
}

variable "timeout" {
  default = "30m"
}

variable "main_node_pool_name" {
}

variable "gpu_node_pool_name" {
}

variable "highmem_node_pool_name" {
}

variable upstream_nameservers {
  description = "List of upstream DNS resolvers (IP addresses) to set in kube-dns ConfigMap as upstreamResolvers, max of 3"
}

variable istio_enabled {
  description = "Boolean, if Istio is enabled (in Kubeflow versions 0.6 and greater)"
  default     = false
}

variable network_policy_enabled {
  description = "Boolean, to enable Network Policy or not"
  default     = true
}

variable mysql_developer_password {
  description = "CloudSQL MySQL instance developer user password"
}

variable mysql_read_only_user_password {
  description = "CloudSQL MySQL instance read only user password"
}
