resource "azurerm_storage_account" "prod" {
  name                      = "${local.resource_prefix}${local.resource_random_suffix}storage"
  resource_group_name       = azurerm_resource_group.storage.name
  location                  = azurerm_resource_group.storage.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
  tags                      = var.tags
}

