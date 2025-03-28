output "nic_ids" {
    description = "Map of Network interface IDs"
    value = { for vm_name, vm_data in azurerm_network_interface.nic : vm_name => vm_data.id }
}

output "nic_private_ips" {
    description = "Map of Network Interface's private IP" 
    value = {
        for k, nic_res in azurerm_network_interface.nic : 
        k => nic_res.ip_configuration[0].private_ip_address
    }
}

output "vm_ids" {
  description = "Map of VM IDs"
  value = {
    for vm_key, vm in azurerm_linux_virtual_machine.vm : vm_key => vm.id
  }
}
