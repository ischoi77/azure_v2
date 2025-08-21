/*
Title: 대규모 infra 구성 및 관리를 위한 Azure 리소스 모듈
Author: 최인석(Choi In-seok)
Email: ischoi77@gmail.com, knight7711@naver.com
Created: 2025-03-28
Description: Azure Backup 모듈 정의
repo_url: https://github.com/ischoi77/Terraform_aws_resource_modules
Version: v2.0.0
*/


##########################################################################
# 로컬 값: 각 VM 항목에서 resource_group_name과 recovery_vault_name 조합으로
# 고유 Recovery Services Vault 목록을 생성합니다.
##########################################################################
locals {
  unique_vaults = {
    for vm_name, vm in var.vm_backups :
    "${vm.resource_group_name}__${vm.recovery_vault_name}" => {
      resource_group_name = vm.resource_group_name,
      recovery_vault_name = vm.recovery_vault_name,
    }
  }

  # 인라인 백업 정책 생성을 위한 대상 VM만 선별
  inline_vm_backups = {
    for vm_name, vm in var.vm_backups :
    vm_name => vm
    if lookup(vm, "backup_policy_id", null) == null
  }
}

##########################################################################
# Recovery Services Vault 생성
#
# 각 고유 조합별로 한 번씩 생성되며, 여러 VM이 동일한 조합을 사용하면
# 동일한 Vault 리소스를 참조하게 됩니다.
##########################################################################
resource "azurerm_recovery_services_vault" "this" {
  for_each = local.unique_vaults

  name                = each.value.recovery_vault_name
  location            = var.location
  resource_group_name = each.value.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true
 
}

##########################################################################
# 인라인 백업 정책 생성 (backup_policy_id가 제공되지 않은 경우)
##########################################################################
resource "azurerm_backup_policy_vm" "policy" {
  for_each = local.inline_vm_backups

  name = each.key
  resource_group_name = each.value.resource_group_name
  # 각 VM의 vault는 고유 조합 키를 이용하여 참조합니다.
  recovery_vault_name = azurerm_recovery_services_vault.this[
    "${each.value.resource_group_name}__${each.value.recovery_vault_name}"
  ].name
  timezone = each.value.backup_policy_config.timezone

  backup {
    frequency = each.value.backup_policy_config.backup_frequency
    time      = each.value.backup_policy_config.backup_time
  }

  retention_daily {
    count = each.value.backup_policy_config.retention_daily_count
  }

  retention_weekly {
    count    = each.value.backup_policy_config.retention_weekly_count
    weekdays = each.value.backup_policy_config.retention_weekly_weekdays
  }

  retention_monthly {
    count         = each.value.backup_policy_config.retention_monthly_count
    weekdays      = each.value.backup_policy_config.retention_monthly_weekdays
    #week_of_month = each.value.backup_policy_config.retention_monthly_week_of_month
  }

  retention_yearly {
    count         = each.value.backup_policy_config.retention_yearly_count
    months         = each.value.backup_policy_config.retention_yearly_month
    weekdays      = each.value.backup_policy_config.retention_yearly_weekdays
    #week_of_month = each.value.backup_policy_config.retention_yearly_week_of_month
  }
 
}

##########################################################################
# 각 VM별 백업 보호 리소스 생성
##########################################################################
resource "azurerm_backup_protected_vm" "protected_vm" {
  for_each = var.vm_backups

  resource_group_name = each.value.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this[
    "${each.value.resource_group_name}__${each.value.recovery_vault_name}"
  ].name

  backup_policy_id = (
    lookup(each.value, "backup_policy_id", null) != null ?
      each.value.backup_policy_id :
      azurerm_backup_policy_vm.policy[each.key].id
  )
  source_vm_id = each.value.vm_id
 
}
