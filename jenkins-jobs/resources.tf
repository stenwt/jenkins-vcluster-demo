data "spectrocloud_cluster" "host_cluster0" {
  name    = "cluster1"
  context = "project"
}

resource "spectrocloud_cluster_group" "cg" {
  name = "cluster-group-demo"

  clusters {
    cluster_uid = data.spectrocloud_cluster.host_cluster0.id
  }
  context = "project"

  config {
    host_endpoint_type       = "LoadBalancer"
    cpu_millicore            = 10000
    memory_in_mb             = 16384
    storage_in_gb            = 10
    oversubscription_percent = 120
  }
}

variable "example-app-image" {
    type        = string
    description = "The name of the container image to use for the virtual cluster in a single scenario"
    default     = "ghcr.io/stenwt/vcluster-app:main"
}

data "spectrocloud_registry" "container_registry" {
  name = "Public Repo"
}

data "spectrocloud_pack_simple" "container_pack" {
  type         = "container"
  name         = "container"
  version      = "1.0.0"
  registry_uid = data.spectrocloud_registry.container_registry.id
}

resource "spectrocloud_application_profile" "example-app" {
  name        = "example"
  description = "example application"
  pack {
    name = "example"
    type = data.spectrocloud_pack_simple.container_pack.type
    registry_uid = data.spectrocloud_registry.container_registry.id
    source_app_tier = data.spectrocloud_pack_simple.container_pack.id
    values = <<-EOT
        pack:
          namespace: "{{.spectro.system.appdeployment.tiername}}-ns"
          releaseNameOverride: "{{.spectro.system.appdeployment.tiername}}"
        containerService:
            serviceName: "{{.spectro.system.appdeployment.tiername}}-svc"
            registryUrl: ""
            image: ${var.example-app-image}
            access: public
            ports:
              - "80"
            serviceType: LoadBalancer
    EOT
  }
  tags = ["example-app"]
}

resource "spectrocloud_virtual_cluster" "cluster" {
  name = "virtual-cluster-jenkins-ci"

  cluster_group_uid = spectrocloud_cluster_group.cg.id

  resources {
    max_cpu       = 3
    max_mem_in_mb = 6000
    min_cpu       = 0
    min_mem_in_mb = 0
    max_storage_in_gb = "0"
    min_storage_in_gb = "0"
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

resource "spectrocloud_application" "example-app-deployment" {
  name                    = "example"
  application_profile_uid = spectrocloud_application_profile.example-app.id

  config {
    cluster_name = spectrocloud_virtual_cluster.cluster.name
    cluster_uid  = spectrocloud_virtual_cluster.cluster.id
  }
  tags = ["example-app"]

  timeouts {
    create = "10m"
    update = "10m"
  }
}
