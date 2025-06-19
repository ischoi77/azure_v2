output "group_info" {
    value = {
        for group_name, group_resource in azuread_group.group :
        group_name => group_resource.id
    }
}