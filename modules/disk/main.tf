resource "azurerm_managed_disk" "disk" {
  for_each = var.managed_disks

  name                 = each.key
  location             = var.location
  resource_group_name  = each.value.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = try(each.value.create_option, "Empty")
  disk_size_gb         = each.value.disk_size_gb
  tags                  = merge(var.common_tags, each.value.tags)
  zone                 = var.vm_zones[each.value.vm_key]
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  for_each = { for key, value in var.managed_disks : key => value if lookup(value, "vm_key", null) != null }

  managed_disk_id    = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id = var.vm_ids[each.value.vm_key]
  lun                = each.value.lun
  caching            = each.value.caching
}