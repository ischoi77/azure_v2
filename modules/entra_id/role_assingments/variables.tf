# variables.tf

variable "role_assignments" {
    type = map(object({
      scope = string
      role_groups = list(string)
    }))
}

variable "group_ids" {
    type = map(string)  
}


variable "role_groups" {
    type = map(list(string))  
}

variable "azurerm_subscription_id" {
    type = string
}


