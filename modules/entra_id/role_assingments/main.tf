####### role_group module


locals {
    role_group_map = { for group, role in var.role_groups : group => roles }
}


# main.tf
resource "azurerm_role_assignment" "role_assignments" {
    for_each = {
        for group_name, group_data in var.role_assignments : 
        group_name => {
            role_groups = group_data.role_groups
            group       = group_name
        }
    }
    role_definition_name = each.value.role_groups[count.index]
    scope = "/subscriptions/${var.azurerm_subscription_id}"
    principal_id = var.group_ids[each.value.group]
    count = length(flatten([for group in each.value.role_groups : local.role_group_map[group]]))
}