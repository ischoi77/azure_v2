variable "recovery_vault_name" {
  description = "Name of the Azure Backup Recovery Services Vault"
  type        = string
}


variable "location" {
  description = "리소스가 생성될 Azure 지역"
  type        = string
}

variable "common_tags" {
  description = "모든 리소스에 적용할 공통 태그"
  type        = map(string)
}

##########################################################################
# 각 VM별 백업 설정 정보를 담은 변수
#
# 각 항목의 구조 (키는 VM 이름):
#   - resource_group_name: 해당 VM의 백업에 사용할 리소스 그룹 이름
#   - recovery_vault_name: 해당 VM의 백업에 사용할 Recovery Services Vault 이름
#   - vm_id: 백업할 가상머신의 Resource ID
#   - backup_policy_id (optional): 미리 생성한 공용 백업 정책 ID (입력 시 인라인 정책 생성 없이 해당 정책 사용)
#   - backup_policy_config (optional): backup_policy_id가 없는 경우, 인라인으로 백업 정책을 생성하기 위한 설정
##########################################################################
variable "vm_backups" {
  description = "각 VM별 백업 설정 정보를 포함하는 변수"
  type = map(object({
    resource_group_name = string
    recovery_vault_name = string
    vm_id               = string
    backup_policy_id    = optional(string)
    backup_policy_config = optional(object({
      timezone                        = string
      backup_frequency                = string  # 예: "Daily", "Weekly" 등
      backup_time                     = string  # HH:MM 형식 (예: "23:00")
      retention_daily_count           = number
      retention_weekly_count          = number
      retention_weekly_weekdays       = list(string)
      retention_monthly_count         = number
      retention_monthly_weekdays      = list(string)
      #retention_monthly_week_of_month = string
      retention_yearly_count          = number
      retention_yearly_month          = string
      retention_yearly_weekdays       = list(string)
      #retention_yearly_week_of_month  = string
    }))
  }))
}
