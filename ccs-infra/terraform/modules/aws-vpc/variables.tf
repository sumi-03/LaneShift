variable "name_prefix" {
  type = string
}

variable "cidr" {
  description = "VPC 전체 대역"
  type        = string
}

variable "azs" {
  description = "사용할 가용 영역. segments의 cidrs와 같은 순서"
  type        = list(string)
}

variable "segments" {
  description = "구간 이름 => AZ별 CIDR, 등급(public | private | isolated)"
  type = map(object({
    cidrs = list(string)
    tier  = string
  }))

  validation {
    condition     = alltrue([for s in var.segments : contains(["public", "private", "isolated"], s.tier)])
    error_message = "tier는 public, private, isolated 중 하나여야 함."
  }
}

variable "enable_nat" {
  description = "private 등급 서브넷의 인터넷 출구(NAT 게이트웨이). 시간당 과금이라 필요할 때만 켬"
  type        = bool
  default     = false
}
