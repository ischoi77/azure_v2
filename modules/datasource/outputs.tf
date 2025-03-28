output "user_assigned_identities_info" {
  value = {
    for name, id in data.azurerm_user_assigned_identity.existing_identities : name => id.id
  }
}

output "subnets_info" {
  value = {
    for name, subnet in data.azurerm_subnet.existing_subnets : name => subnet.id
  }
}


locals {
  # Virtual Machine 값이 있으면 리스트로, 없으면 빈 리스트
  vm_values = length(values(data.azurerm_virtual_machine.vm)) > 0 ? values(data.azurerm_virtual_machine.vm) : []
  vm_ids_by_rg = length(local.vm_values) > 0 ? {
    for rg in distinct([for vm in local.vm_values : vm.resource_group_name]) :
    rg => {
      for vm in local.vm_values : vm.name => vm.id if vm.resource_group_name == rg
    }
  } : {}
  # Virtual Machine 값이 있으면 리스트로, 없으면 빈 리스트
  vm_od_values = length(values(data.azurerm_managed_disk.vm_osdisk)) > 0 ? values(data.azurerm_managed_disk.vm_osdisk) : []
  vm_od_by_rg = length(local.vm_od_values) > 0 ? {
    for rg in distinct([for vm_od in local.vm_od_values : vm_od.resource_group_name]) :
    rg => {
      for vm_od in local.vm_od_values : vm_od.name => vm_od.id if vm_od.resource_group_name == rg
    }
  } : {}


  # Network Interface 값이 있으면 리스트로, 없으면 빈 리스트
  nic_values = length(values(data.azurerm_network_interface.nic)) > 0 ? values(data.azurerm_network_interface.nic) : []
  nic_ids_by_rg = length(local.nic_values) > 0 ? {
    for rg in distinct([for nic in local.nic_values : nic.resource_group_name]) :
    rg => {
      for nic in local.nic_values : nic.name => nic.id if nic.resource_group_name == rg
    }
  } : {}

  # Storage Account 값이 있으면 리스트로, 없으면 빈 리스트
  storage_values = length(values(data.azurerm_storage_account.storage)) > 0 ? values(data.azurerm_storage_account.storage) : []
  storage_ids_by_rg = length(local.storage_values) > 0 ? {
    for rg in distinct([for sa in local.storage_values : sa.resource_group_name]) :
    rg => {
      for sa in local.storage_values : sa.name => sa.id if sa.resource_group_name == rg
    }
  } : {}
}

output "vm_ids" {
  description = "리소스 그룹별 Virtual Machine의 ID (리소스 그룹 > VM 이름). vm_names 목록이 존재하는 경우에만 값이 생성됩니다."
  value       = local.vm_ids_by_rg
}

output "vm_od" {
  description = "리소스 그룹별 Virtual Machine의 OSDISK (리소스 그룹 > VM 이름). vm_names 목록이 존재하는 경우에만 값이 생성됩니다."
  value       = local.vm_od_by_rg
}


output "nic_ids" {
  description = "리소스 그룹별 Network Interface의 ID (리소스 그룹 > NIC 이름). nic_names 목록이 존재하는 경우에만 값이 생성됩니다."
  value       = local.nic_ids_by_rg
}

output "storage_account_ids" {
  description = "리소스 그룹별 Storage Account의 ID (리소스 그룹 > Storage Account 이름). storage_account_names 목록이 존재하는 경우에만 값이 생성됩니다."
  value       = local.storage_ids_by_rg
}

output "container_ids" {
  description = "Storage Account의 컨테이너 IDs. storage_account_names 목록이 존재하는 경우에만 값이 생성됩니다."
  value = { for k, v in data.azurerm_storage_containers.containers : k => v.id }
}