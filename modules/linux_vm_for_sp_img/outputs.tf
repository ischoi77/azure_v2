output "vm_ids" {
  description = "Map of VM IDs"
  value = {
    for vm_key, vm in azurerm_virtual_machine.vm : vm_key => vm.id
  }
}


output "vm_zones" {
  description = "Map of VM AZ info"
  value = {
    for vm_zone, vm in azurerm_virtual_machine.vm : vm_zone => vm.zones[0]
  }
}
