# variables.tf

variable "env" {
    type = string
}

# variable "ad_groups" {
#     type = map(object({
#         user = list(string)
#     }))
# }


variable "group_names" {
    type = list(string)
}

