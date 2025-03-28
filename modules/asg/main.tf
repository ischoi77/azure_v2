resource "azurerm_application_security_group" "asg" {
    for_each = var.asgs
    
    name                = each.key
    location            = var.location
    resource_group_name = each.value.resource_group_name
    tags                = merge(var.common_tags, each.value.tags)
}


resource "azurerm_network_interface_application_security_group_association" "asg_association" {
    for_each = {
        for asg_name, asg_data in var.asgs :
        asg_name => asg_data if length(asg_data.attach_nic_names) > 0
    }

    count = length(each.value.attach_nic_names)

    network_interface_id = var.nic_ids_map[each.value.attach_nic_names[count.index]]
    application_security_group_id = azurerm_application_security_group.asg[each.key].id                             
}
