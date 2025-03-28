output "route_table_ids" {
  value = {for k, v in azurermazurerm_route_table.route_tables : k => v.id }
}

