data "spectrocloud_cluster_group" "cg" { 
  name = "cluster-group-demo"
  context = "project"
}

resource "spectrocloud_virtual_cluster" "cluster" {
  name = "virtual-cluster-jenkins-ci"

  cluster_group_uid = data.spectrocloud_cluster_group.cg.id

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
