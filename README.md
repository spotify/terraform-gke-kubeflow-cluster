# terraform-gke-kubeflow-cluster

[![lifecycle](https://img.shields.io/badge/lifecycle-alpha-blue.svg)](https://img.shields.io/badge/lifecycle-alpha-blue.svg)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE.txt)

A [Terraform][] module for creating a GKE cluster to run Kubeflow on.

This module creates a GKE cluster similiar to how the [`kfctl`][kfctl] tool
does, with a few changes:

- adds a Cloud SQL instance to use for the metadata store/databases
- creates a GCE Persistent Disk to use for the artifact store

This module was originally created by the ML Infrastructure team at Spotify to
create and manage long-lived GKE clusters for many Kubeflow-using teams at
Spotify to use, whereas the `kfctl` tool and documentation around creating a
cluster for Kubeflow tends to assume that individual clusters are quickly
spun-up and torn-down by engineers using Kubeflow. For more details on how
Spotify's centralized Kubeflow platform, see [this talk from Kubecon North
America 2019][kubecon-talk].

[Terraform]: https://www.terraform.io
[kubecon-talk]: https://www.youtube.com/watch?v=m9XhsnNSMAI

## Usage

To use this within Terraform, add a `module` block like:

```hcl
# TODO: not sure if this is correct, will doublecheck after first release to https://www.terraform.io/docs/registry/modules/publish.html
module "kubeflow_cluster" {
  source = "spotify/gke-kubeflow-cluster"
}
```

## Module details

The `terraform-gke-kubeflow-cluster` module creates the following resources:

- a GKE cluster (attached to a Shared VPC if the relevant parameters for
  networks/subnetworks are set)
- a Cloud SQL instance to use for the metadata store/databases
- a GCE Persistent Disk to use for Argo's artifact store
- GCP service accounts for Kubeflow to use (distinct accounts per cluster):
  - an "admin" service account (used for IAP - which is not included in this
    module)
  - the "user" service account for Kubeflow pipelines to use
  - the VM service account used by the GKE cluster/nodes itself
- IAM bindings for the above service accounts
- Kubernetes secrets for:
  - `cloudsql-instance-credentials` for the cloudsql-proxy connected to the metadata SQL instance
  - `admin-gcp-sa` containing the "admin" GCP service account for Kubeflow
  - `user-gcp-sa` containing the "user" GCP service account for Kubeflow

Each "instantiation" of the module creates a new set of all of these resources
- the intent of the module is to automate the entire setup of all of the GCP
resources needed to run a Kubeflow cluster.

This repo does _not_ currently actually install the Kubeflow system components
on the cluster - use [kfctl][] or another tool for that.

## Local development

Run the following commands from the root of the project:

1. `brew install tfenv` -- install [tfenv][]
1. `tfenv install` -- install the version of Terraform specified in
   `.terraform-version` in source control
1. `terraform init` -- setup terraform providers

## Note on master and node version values

The expected behavior of fuzzy versions for `min_master_version` and
`node_version` is [undocumented][1] ([Github issue][2]). From empirical
evidence, the behavior so far is that the most recent version that matches the
fuzzy version is used. For example, `node_version = "1.11"` results in GKE
nodes running 1.11.7-gke.6 if that's the most recent version.

## Releasing new versions of the module

See https://www.terraform.io/docs/registry/modules/publish.html#releasing-new-versions

A webhook has been automatically added to the repo, and a new "release" will be 
visible in the Terraform Registry whenever a new tag is pushed that looks like a 
semantic version (e.g. "v1.2.3"). So to cut a release, simply tag a commit and 
make sure to push the tag to Github with `git push --tags`.

## Code of Conduct
This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.

[1]: https://www.terraform.io/docs/providers/google/r/container_cluster.html#min_master_version
[2]: https://github.com/terraform-providers/terraform-provider-google/issues/3155
[tfenv]: https://github.com/tfutils/tfenv
[kfctl]: https://www.kubeflow.org/docs/gke/deploy/deploy-cli/
[code-of-conduct]: https://github.com/spotify/code-of-conduct/blob/master/code-of-conduct.md
