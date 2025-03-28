output "cost_management_export_ids" {
  description = "생성된 cost management export 리소스의 ID 목록"
  value       = { for key, exp in azurerm_subscription_cost_management_export.this : key => exp.id }
}
