variable "user_assigned_identities" {
  description = "Map of User Assigned Identities with identity name as key and resource group name as value"
  type = map(string)
}


variable "subnets" {
  description = "Map of Subnets with subnet name as key and a map containing resource group and virtual network name"
  type = map(object({
    resource_group_name = string
    virtual_network_name = string
  }))
}


variable "resources" {
  description = <<-EOT
    리소스 그룹명을 key로 하여, 각 리소스 그룹에서 조회할 리소스 타입별로  
    조회할 리소스 이름 목록을 지정합니다.
    
    예)
      "prod-resource-group" = {
        vm_names              = ["prod-vm-1", "prod-vm-2"]
        nic_names             = []                     # 빈 리스트 → NIC 조회 안 함
        storage_account_names = ["prod-sa-1", "prod-sa-2"]
      }
  EOT

  type = map(object({
    vm_names              = list(string)
    nic_names             = list(string)
    storage_account_names = list(string)
  }))
}


locals {
  # Virtual Machine 정보: vm_names 리스트에 값이 있는 경우에만
  vm_info = flatten([
    for rg, conf in var.resources : length(conf.vm_names) > 0 ? [
      for vm_name in conf.vm_names : {
        resource_group = rg
        name           = vm_name
      }
    ] : []
  ])

  # vm_osdisk = flatten([
  #   for rg, conf in var.resources : length(conf.vm_names) > 0 ? [
  #     for vm_name in conf.vm_names : {
  #       resource_group = rg
  #       name           = vm_name
  #     }
  #   ] : []
  # ])


  # Network Interface 정보: nic_names 리스트에 값이 있는 경우에만
  nic_info = flatten([
    for rg, conf in var.resources : length(conf.nic_names) > 0 ? [
      for nic_name in conf.nic_names : {
        resource_group = rg
        name           = nic_name
      }
    ] : []
  ])

  # Storage Account 정보: storage_account_names 리스트에 값이 있는 경우에만
  storage_info = flatten([
    for rg, conf in var.resources : length(conf.storage_account_names) > 0 ? [
      for sa_name in conf.storage_account_names : {
        resource_group = rg
        name           = sa_name
      }
    ] : []
  ])
}
