variable "name_prefix" {
  type = string
}

variable "external_network_name" {
  description = "라우터 외부 게이트웨이로 쓸 기존 외부망 이름"
  type        = string
}

variable "dns_nameservers" {
  type = list(string)
}

variable "segments" {
  description = "구간 이름 => CIDR, 할당 범위(선택)"
  type = map(object({
    cidr = string
    allocation_pool = optional(object({
      start = string
      end   = string
    }))
  }))
}
