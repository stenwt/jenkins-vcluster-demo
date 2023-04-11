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
    #values= <<-EOT
    #  isolation:
    #    enabled: true
    #    limitRange:
    #      default:
    #        cpu: 10000m
    #        ephemeral-storage: 500Gi
    #        memory: 16384Mi
    #      defaultRequest:
    #        cpu: 250m
    #        ephemeral-storage: 0
    #        memory: 256Mi
    #      enabled: true
    #EOT
  }
}

data "spectrocloud_registry_helm" "helm" {
  name = "Bitnami"
}

data "spectrocloud_pack" "jenkins" {
  name         = "jenkins"
  registry_uid = data.spectrocloud_registry_helm.helm.id
  version      = "12.0.4"
}

resource "spectrocloud_cluster_profile" "jenkins-app-profile" {
  name        = "jenkins-app-profile"
  description = "A profile for Jenkins"
  context     = "project"
  pack {
    name            = data.spectrocloud_pack.jenkins.name
    type            = "helm"
    tag             = "1.0.0"
    registry_uid    = data.spectrocloud_registry_helm.helm.id
    uid = data.spectrocloud_pack.jenkins.id
    values = <<-EOT
      pack:
        namespace: "jenkins"
      jenkinsUser: "jenkins"
      jenkinsPassword: "spectrocloud"
      agent:
        resources:
          limits:
            cpu: 1000m
            memory: 1024Mi
          requests:
            cpu: 256m
            memory: 256Mi
      resources:
        limits:
          cpu: 1000m
          memory: 1024Mi
        requests:
          cpu: 256m
          memory: 256Mi
      persistence:
        enabled: false
      plugins: 
      - kubernetes
      #- git
      #- configuration-as-code
      #- pipeline
    EOT
  }
  tags = ["name:jenkins", "terraform_managed:true"]
}

resource "spectrocloud_virtual_cluster" "cluster" {
  name = "virtual-cluster-jenkins-ops"

  cluster_group_uid = spectrocloud_cluster_group.cg.id
  #host_cluster_uid = data.spectrocloud_cluster.host_cluster0.id

  cluster_profile {
    id = spectrocloud_cluster_profile.jenkins-app-profile.id
  }

  resources {
    max_cpu       = 3
    max_mem_in_mb = 6000
    min_cpu       = 0
    min_mem_in_mb = 0
    max_storage_in_gb = "9"
    min_storage_in_gb = "5"
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}
