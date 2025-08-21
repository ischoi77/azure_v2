/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure ASG 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/


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
