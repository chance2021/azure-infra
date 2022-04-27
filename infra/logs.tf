resource "azurerm_log_analytics_workspace" "prod" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${local.log_analytics_workspace_name}${local.resource_random_suffix}-loganalytics"
  location            = var.log_analytics_workspace_location
  resource_group_name = azurerm_resource_group.compute.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "prod" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.prod.location
  resource_group_name   = azurerm_resource_group.compute.name
  workspace_resource_id = azurerm_log_analytics_workspace.prod.id
  workspace_name        = azurerm_log_analytics_workspace.prod.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

