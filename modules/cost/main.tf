data "azurerm_subscription" "current" {}

resource "azurerm_subscription_cost_management_export" "this" {
  for_each = var.cost_management_exports

  name                         = each.key
  subscription_id              = data.azurerm_subscription.current.subscription_id
  recurrence_type              = each.value.recurrence_type
  recurrence_period_start_date = each.value.recurrence_period_start_date
  recurrence_period_end_date   = each.value.recurrence_period_end_date
  active                       = lookup(each.value, "active", true)

  export_data_storage_location {
    container_id     = var.container_ids[each.value.export_data_storage_location.container_name]
    root_folder_path = each.value.export_data_storage_location.root_folder_path
  }

  export_data_options {
    type       = each.value.export_data_options.type
    time_frame = each.value.export_data_options.time_frame
  }
}
