resource "azurerm_resource_group" "example" {
  name     = var.azure_resource_group
  location = var.azure_region
}
