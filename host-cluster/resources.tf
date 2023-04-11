
resource "spectrocloud_cloudaccount_azure" "account" {
  name                = var.cloud_account_name
  azure_tenant_id     = var.azure_tenant_id
  azure_client_id     = var.azure_client_id
  azure_client_secret = var.azure_client_secret
}
data "spectrocloud_registry" "registry" {
  name = "Public Repo"
}

data "spectrocloud_registry" "private-registry" {
  name = "private-registry"
}

data "spectrocloud_pack" "csi" {
  name = "csi-azure"
  registry_uid = data.spectrocloud_registry.registry.id
  version  = "1.25.0"
}

data "spectrocloud_pack" "cni" {
  name    = "cni-kubenet"
  registry_uid = data.spectrocloud_registry.registry.id
  version = "1.0.0"
}

data "spectrocloud_pack" "k8s" {
  name    = "kubernetes-aks"
  registry_uid = data.spectrocloud_registry.registry.id
  version = "1.23"
}

data "spectrocloud_pack" "ubuntu" {
  name = "ubuntu-aks"
  registry_uid = data.spectrocloud_registry.registry.id
  version  = "18.04"
}

resource "spectrocloud_cluster_profile" "infra-profile" {
  name        = var.sc_cp_infra_profile_name
  description = var.sc_cp_infra_profile_description
  tags        = var.sc_cp_infra_profile_tags
  cloud       = "aks"
  type        = "cluster"
  version     = var.sc_cp_infra_profile_version

  pack {
    name   = "ubuntu-aks"
    tag    = data.spectrocloud_pack.ubuntu.version
    uid    = data.spectrocloud_pack.ubuntu.id
    values = data.spectrocloud_pack.ubuntu.values
  }

  pack {
    name   = "kubernetes-aks"
    tag    = data.spectrocloud_pack.k8s.version
    uid    = data.spectrocloud_pack.k8s.id
    values = data.spectrocloud_pack.k8s.values
  }
  
  pack {
    name   = "cni-kubenet"
    tag    = data.spectrocloud_pack.cni.version
    uid    = data.spectrocloud_pack.cni.id
    values = data.spectrocloud_pack.cni.values
  }

  pack {
    name   = "csi-azure"
    tag    = data.spectrocloud_pack.csi.version
    uid    = data.spectrocloud_pack.csi.id
    values = data.spectrocloud_pack.csi.values
  }

}

resource "spectrocloud_cluster_aks" "aks" {
  name               = var.aks_cluster_name
  cloud_account_id   = spectrocloud_cloudaccount_azure.account.id

  cluster_profile {
    id = spectrocloud_cluster_profile.infra-profile.id
  }

  cloud_config {
    subscription_id = var.azure_subscription_id
    resource_group  = var.azure_resource_group
    region          = var.azure_region
    ssh_key         = var.cluster_ssh_public_key
  }

  host_config { 
    host_endpoint_type = "LoadBalancer"
  }

  machine_pool {
    name                 = "system"
    count                = 1
    instance_type        = "Standard_D4s_v5"
    disk_size_gb         = 50
    is_system_node_pool  = true
    storage_account_type = "Premium_LRS"
  }  

  machine_pool {
    name                 = "application"
    count                = 2
    instance_type        = "Standard_D4s_v5"
    disk_size_gb         = 50
    is_system_node_pool  = false
    storage_account_type = "Premium_LRS"
  }

# Using depends_on to ensure azure rg is created before creating cluster
# also not deleted until cluster is deleted
  depends_on = [
    azurerm_resource_group.example,
  ]

  timeouts {
    create = "50m"
    update = "50m"
  }
}
}
