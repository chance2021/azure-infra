# Public Ip for APP gatweay
resource "azurerm_public_ip" "prod" {
  name                = "${local.resource_prefix}-${local.resource_random_suffix}-pip"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.resource_prefix}-pip"

  tags = var.tags
}
data "azurerm_public_ip" "prod" {
  name                = azurerm_public_ip.prod.name
  resource_group_name = azurerm_public_ip.prod.resource_group_name
}

# Vnet

resource "azurerm_virtual_network" "prod" {
  name                = local.virtual_network_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = [var.virtual_network_address_prefix]

  # subnet {
  #   name           = var.appgw_subnet_name
  #   address_prefix = var.app_gateway_subnet_address_prefix
  #   security_group = azurerm_network_security_group.prod.id
  # }
  tags       = var.tags
  depends_on = [azurerm_network_security_group.prod, azurerm_network_security_rule.appgw, azurerm_network_security_rule.http, azurerm_network_security_rule.https]
}

resource "azurerm_subnet" "appgwsubnet" {
  name                 = var.appgw_subnet_name
  resource_group_name  = azurerm_resource_group.network.name
  address_prefix       = var.app_gateway_subnet_address_prefix
  virtual_network_name = azurerm_virtual_network.prod.name
  depends_on           = [azurerm_virtual_network.prod]
}

resource "azurerm_subnet_network_security_group_association" "appgwsubnet" {
  subnet_id                 = azurerm_subnet.appgwsubnet.id
  network_security_group_id = azurerm_network_security_group.prod.id
  depends_on                = [azurerm_subnet.appgwsubnet, azurerm_network_security_group.prod, azurerm_network_security_rule.http, azurerm_network_security_rule.https]
}

resource "azurerm_subnet" "kubesubnet" {
  name                                           = var.compute_subnet_name
  resource_group_name                            = azurerm_resource_group.network.name
  virtual_network_name                           = azurerm_virtual_network.prod.name
  address_prefixes                               = [var.compute_subnet_address_prefix]
  enforce_private_link_endpoint_network_policies = true
  service_endpoints                              = ["Microsoft.Storage", "Microsoft.KeyVault"]
  depends_on                                     = [azurerm_virtual_network.prod]
}

resource "azurerm_subnet_network_security_group_association" "kubesubnet" {
  subnet_id                 = azurerm_subnet.kubesubnet.id
  network_security_group_id = azurerm_network_security_group.prod.id
  depends_on                = [azurerm_subnet.kubesubnet, azurerm_network_security_group.prod, azurerm_network_security_rule.http, azurerm_network_security_rule.https]
}

## Network Security Group
resource "azurerm_network_security_group" "prod" {
  name                = "${local.resource_prefix}-${local.resource_random_suffix}-nsg"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location

  # security_rule {
  #   name                       = "APPGW"
  #   priority                   = 130
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "65200-65535"
  #   source_address_prefix      = "GatewayManager"
  #   destination_address_prefix = "*"
  # }

  tags = var.tags
}

resource "azurerm_network_security_rule" "appgw" {
  name                        = "APPGW"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.prod.name
  depends_on                  = [azurerm_network_security_group.prod]
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS_443"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.prod.name
  depends_on                  = [azurerm_network_security_group.prod]
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.user_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.prod.name
  depends_on                  = [azurerm_network_security_group.prod]
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP_80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.prod.name
  depends_on                  = [azurerm_network_security_group.prod]
}

