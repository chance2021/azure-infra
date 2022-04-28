
variable "resource_group_name" {
  description = "Resource group name."
}

variable "storage_account_name" {
  description = "Storage account name."
}

variable "client_id" {
  description = "Client Id of the service principal."
}

variable "client_secret" {
  description = "Client password of the service principal."
}

variable "prefix" {
  description = "Prefix to append at the begining of all azure resource name"
}

resource "random_id" "random" {
  byte_length = 2
}

## Resources Config
variable "location" {
  default = "canadacentral"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "canadacentral"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}
variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
    env    = "Production"
  }
}

## Resource Locals
locals {
  ## Prefix for all resources to ensure unique naming which is required for most of the resources to be deploy
  resource_prefix        = var.prefix
  resource_random_suffix = random_id.random.dec
  ##resource groups
  storage_resource_group_name = "${var.prefix}-storage-rg"
  compute_resource_group_name = "${var.prefix}-compute-rg"
  network_resource_group_name = "${var.prefix}-network-rg"
  ##logs
  log_analytics_workspace_name = "${var.prefix}logs"
  log_retention_days           = 90
  ## compute
  cluster_name       = "${var.prefix}-${random_id.random.dec}-k8s"
  admin_user_name    = "${var.prefix}adm01"
  compute_dns_prefix = "${var.prefix}-${random_id.random.dec}k8s"
}

# # Network locals
locals {
  ##VNET
  virtual_network_name = "${var.prefix}-${random_id.random.dec}-vnet"
  ## Application Gateway
  app_gateway_name               = "${var.prefix}-${random_id.random.dec}-appgw"
  backend_address_pool_name      = "${azurerm_virtual_network.prod.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.prod.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.prod.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.prod.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.prod.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.prod.name}-rqrt"
  app_gateway_subnet_name        = var.appgw_subnet_name
}


## Network

variable "virtual_network_address_prefix" {
  description = "VNET address prefix"
  default     = "15.0.0.0/8"
}

variable "compute_subnet_name" {
  description = "Subnet Name"
  default     = "computesubnet"
}

variable "compute_subnet_address_prefix" {
  description = "Subnet address prefix"
  default     = "15.0.0.0/16"
}

variable "appgw_subnet_name" {
  description = "Subnet Name"
  default     = "appgwsubnet"
}

variable "app_gateway_subnet_address_prefix" {
  description = "Subnet server IP address"
  default     = "15.1.0.0/16"
}

variable "user_ip" {
  description = "User IP address"
}
## Compute Config

variable "node_count" {
  description = "The number of agent nodes for the cluster."
  default     = 1
}

variable "compute_size" {
  description = "VM SKU"
  default     = "standard_ds2_v2"
}

variable "os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 60
}




##AKS

variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
  default     = "true"
}

