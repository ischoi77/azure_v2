output "recovery_vault_ids" {
  description = "생성된 Recovery Services Vault 리소스들의 ID (고유 조합 키 기준)"
  value = { for key, vault in azurerm_recovery_services_vault.this : key => vault.id }
}

output "backup_policy_ids" {
  description = "각 VM별로 적용된 백업 정책 ID (입력된 값 또는 인라인 생성된 정책 ID)"
  value = {
    for vm_name, vm in var.vm_backups :
    vm_name => (
      lookup(vm, "backup_policy_id", null) != null ?
      vm.backup_policy_id :
      azurerm_backup_policy_vm.policy[vm_name].id
    )
  }
}

output "backup_protected_vm_ids" {
  description = "백업 보호 대상 VM 리소스들의 ID"
  value = { for vm_name, bp in azurerm_backup_protected_vm.protected_vm : vm_name => bp.id }
}
