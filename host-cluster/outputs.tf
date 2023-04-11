output "clusterprofile_infra_id" {
  value = spectrocloud_cluster_profile.infra-profile.id
}
output "cluster_id" {
  value = spectrocloud_cluster_aks.aks.id
}
output "cluster_kubeconfig" {
  value = local.cluster_kubeconfig
}


