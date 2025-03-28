output "public_ip_ids" {
    value = { for name, public_ip in azurermazurerm_public_ip.public_ips : name => public_ip_id }
}