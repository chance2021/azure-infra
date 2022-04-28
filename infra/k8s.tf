resource "azurerm_kubernetes_cluster" "compute" {
  name       = local.cluster_name
  location   = azurerm_resource_group.compute.location
  dns_prefix = local.compute_dns_prefix

  resource_group_name = azurerm_resource_group.compute.name

  lifecycle {
    ignore_changes = [addon_profile]
  }

  #  linux_profile {
  #    admin_username = local.admin_user_name

  # TODO: Figure out SSH key management
  #    ssh_key {
  #      key_data = file(var.public_ssh_key_path)
  #    }
  #  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.prod.id
    }
  }

  default_node_pool {
    name                = "agentpool"
    node_count          = var.node_count
    vm_size             = var.compute_size
    os_disk_size_gb     = var.os_disk_size
    vnet_subnet_id      = azurerm_subnet.kubesubnet.id
    enable_auto_scaling = true
    max_count           = 6
    min_count           = 1
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }

  role_based_access_control {
    enabled = var.aks_enable_rbac
  }

#  api_server_authorized_ip_ranges = [var.user_ip,
#  var.virtual_network_address_prefix]
  depends_on = [azurerm_application_gateway.prod, azurerm_subnet.kubesubnet]

  tags       = var.tags

  identity {
    type = "SystemAssigned"
  }
}

