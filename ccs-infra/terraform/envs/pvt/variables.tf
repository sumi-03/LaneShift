variable "name_prefix" {
  type = string
}

variable "external_network_name" {
  type = string
}

variable "dns_nameservers" {
  type = list(string)
}

variable "segments" {
  type = map(object({
    cidr = string
    allocation_pool = optional(object({
      start = string
      end   = string
    }))
  }))
}

variable "image_name" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "vpn_local_cidrs" {
  description = "VPN으로 AWS와 통할 프라이빗 대역 (차량접속 제외)"
  type        = list(string)
}

variable "k8s_worker_count" {
  type    = number
  default = 3
}

variable "metallb_pool_cidr" {
  description = "MetalLB가 나눠 줄 차량접속 구간 IP (DHCP 범위 밖)"
  type        = string
}
