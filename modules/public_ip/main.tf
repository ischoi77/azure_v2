/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Public IP 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

resource "azurerm_public_ip" "public_ips" {
    for_each            = var.public_ips
    name                = each.key
    location            = var.location
    resource_group_name = each.value.resource_group_name
    allocation_method   = "Static"
    sku                 = each.value.sku
    ddos_protection_mode = try(each.value.ddos_protection_mode, null)
    ddos_protection_plan_id = var.ddos[each.value.ddos_plan].id
    tags                = merge(var.common_tags, each.value.tags)
}