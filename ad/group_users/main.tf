##########groups_users module
locals {
  ad_groups = {
    for group_name in var.group_names : group_name => {
        user = split("\n", file("${path.module}/users/azure/${var.env}/azuread_groups/${group_name}.user"))
    }
  }
}

resource "azuread_group" "group" {
    for_each = local.ad_groups # 파일 유저 목록 사용시
    display_name =  each.key
    security_enabled = true
}

data "azuread_user" "user" {
    for_each            = toset(flatten([for group in local.ad_groups : group.user]))
    user_principal_name = each.value
}


resource "azuread_group_member" "group_member" {
    for_each         = {
        for group_name, group_data in local.ad_groups :
        group_name => group_data.user if length(group_data.user) > 0 
    }
    member_object_id = [
        for email in each.value.user :
        data.azuread_user.user[email].id
    ]
    group_object_id  = azuread_group.group[each.key].id
}


