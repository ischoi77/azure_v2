resource "azurerm_network_ddos_protection_plan" "ddos_protection_plan" {
    for_each = var.ddos_protection_plans
    name                = each.key
    location            = var.location
    resource_group_name = each.value.resource_group_name
    
    tags = merge(var.common_tags, each.value.tags)
}
