variable "location" {
  description = "리전 정보(위치) 값"
  type        = string
}

variable "common_tags" {
  description = "공용 tag 값 (리소스별 개별 tags와 병합됨)"
  type        = map(string)
}

variable "container_ids" {
  description = "Storage Container의 이름과 해당 Resource Manager ID를 매핑한 변수"
  type        = map(string)
}

variable "cost_management_exports" {
  description = "Map 형태로 정의된 cost management export 구성. map의 key 값이 export의 이름으로 사용됩니다."
  type = map(object({
    recurrence_type                  = string
    recurrence_period_start_date     = string
    recurrence_period_end_date       = string

    export_data_storage_location = object({
      container_name   = string
      root_folder_path = string
    })

    export_data_options = object({
      type       = string
      time_frame = string
    })

    active = optional(bool)
    tags   = optional(map(string))
  }))
}
