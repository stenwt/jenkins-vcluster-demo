variable "sc_host" {
  description = "Spectro Cloud Endpoint"
  default     = "api.spectrocloud.com"
}

variable "sc_project_name" {
  description = "Spectro Cloud Project (e.g: Default)"
  default     = "Default"
}

variable "sc_api_key" {} 

variable "cluster_ssh_public_key" {
  description = "The public SSH key to inject into the nodes"
}

variable "cloud_account_name" {}
variable "azure_tenant_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_subscription_id" {}
variable "azure_resource_group" {}
variable "azure_region" {}


variable "aks_cluster_name" {}
variable "sc_cp_infra_profile_name" {}
variable "sc_cp_infra_profile_version" {}
variable "sc_cp_infra_profile_description" {}
variable "sc_cp_infra_profile_tags" {}
