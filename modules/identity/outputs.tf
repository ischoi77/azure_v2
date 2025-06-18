output "identity_ids" {
    value = {
        for name, identity in azurerm_user_assigned_identity.user_assigned_identitys : name => identity.id
    }
}
