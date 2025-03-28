output "acr_ids" {
  description = "acr IDs"
  value = {
    for k , v in azurerm_container_registry.acr : k => v.id
  }
}
