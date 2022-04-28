resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.compute]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.compute.kube_config_raw
}

output "compute_resource_group" {
  value = azurerm_resource_group.compute.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.compute.name
}

#output "storage_account_name" {
#  value = azurerm_storage_account.prod.name
#}

output "client_key" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.client_key
}

output "client_certificate" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.client_certificate
}

output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.cluster_ca_certificate
}

output "cluster_username" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.username
}

output "cluster_password" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.password
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.compute.kube_config_raw
    sensitive = true
}

output "host" {
    value = azurerm_kubernetes_cluster.compute.kube_config.0.host
}
