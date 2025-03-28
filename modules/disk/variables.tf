variable "managed_disks" {
  description = "Map of managed disks configurations"
  type = map(object({
    #name                 = string
    resource_group_name  = string
    #location            = string
    disk_size_gb         = number
    storage_account_type = string
    lun                  = number
    vm_key               = optional(string)
    caching              = string
    tags                 = optional(map(string))
  }))
}


variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}

variable "vm_ids" {
    type = map(string)  
}

variable "vm_zones" {
    type = map(string)  
}