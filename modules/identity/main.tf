/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure 관리 ID 모듈 정의
repo_url: https://github.com/ischoi77/azure_v2
Version: v2.0.0
*/

resource "azurerm_user_assigned_identity" "user_assigned_identitys" {
    for_each = var.user_assigned_identities
    location            = var.location
    name                = each.key
    resource_group_name = each.value.resource_group_name
    tags = merge(var.common_tags, each.value.tags)
}

resource "azurerm_role_assignment" "role_assignment" {
    for_each = { for key, val in var.user_assigned_identities : key => val.roles }
    principal_id = azurerm_user_assigned_identity.user_assigned_identitys[key].principal_id
    scope = each.value[0].scope
    role_definition_name = each.value[0].role_definition_name
  
}


