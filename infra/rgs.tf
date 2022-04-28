resource "azurerm_resource_group" "storage" {
  name     = local.storage_resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_resource_group" "compute" {
  name     = local.compute_resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_resource_group" "network" {
  name     = local.network_resource_group_name
  location = var.location
  tags     = var.tags
}
