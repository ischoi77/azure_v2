locals {
  keycloak_groups = {
    for group_name in var.keycloak_group_names : group_name => {
        user = split("\n", file("${path.module}/users/azure/${var.env}/keycloak_groups/${group_name}.user"))
    }
  }
}

# create user group
resource "keycloak_group" "user_group" {
    for_each = local.keycloak_groups
    realm_id = var.realm_id
    name     = each.key
}



resource "keycloak_group_memberships" "members" {
    for_each         = {
        for group_name, group_data in local.keycloak_groups :
        group_name => group_data.user if length(group_data.user) > 0 
    }
    realm_id = var.realm_id
    group_id = keycloak_group.user_group[each.key].id
    members  = [
            for email in each.value.user : local.keycloak_group.user
    ]
}


