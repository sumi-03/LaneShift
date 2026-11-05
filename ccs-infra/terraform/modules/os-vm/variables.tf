variable "name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "flavor_name" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "networks" {
  description = "붙일 망 목록. 첫 번째가 기본 NIC이고 floating IP도 여기에 붙는다"
  type = list(object({
    network_id            = string
    subnet_id             = string
    security_group_ids    = optional(list(string))     # 없으면 공통 security_group_ids 사용
    allowed_address_pairs = optional(list(string), []) # 이 포트에서만 통과시킬 대역
  }))
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "floating_ip_pool" {
  description = "floating IP를 받을 외부망 이름. null이면 붙이지 않음"
  type        = string
  default     = null
}

variable "user_data" {
  type    = string
  default = null
}

variable "allowed_address_pairs" {
  description = "첫 번째 포트에서 자기 IP가 아니어도 통과시킬 대역 (라우터 역할 VM용)"
  type        = list(string)
  default     = []
}
