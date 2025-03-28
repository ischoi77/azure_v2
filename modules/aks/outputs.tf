output "kubernetes_cluster_ids" {
  description = "The IDs of the created Kubernetes clusters."
  value       = { for k, v in azurerm_kubernetes_cluster.aks : k => v.id }
}
