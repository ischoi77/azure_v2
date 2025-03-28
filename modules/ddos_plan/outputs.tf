output "ddos_ids" {
    value = {
        for name, ddos in azurerm_network_ddos_protection_plan.ddos_protection_plan : name => ddos.id
    }
  
}