terraform {
  required_providers {
    spectrocloud = {
      source  = "spectrocloud/spectrocloud"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "spectrocloud" {
  host         = var.sc_host
  project_name = var.sc_project_name
  api_key      = var.sc_api_key
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}
