output "subnet_ids" {
    value = {
        for name, subnet in azurerm_subnet.subnets : name => subnet.id
    }
}

output "vnet_ids" {
    value = {
        for name, vnet in azurerm_virazurerm_virtual_network.vnets : name => vnet.id
    }
  
}