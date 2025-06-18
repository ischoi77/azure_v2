variable "location" {
    type = string
}

variable "common_tags" {
    type = map(string)
}


variable "user_assigned_identities" {
    type = map(object({
      resource_group_name = string
      tags = map(string)
      roles = list(object({
        scope = string
        role_definition_name = string
      }))
    })) 
}