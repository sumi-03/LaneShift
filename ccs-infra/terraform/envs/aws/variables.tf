variable "github_repo" {
  description = "OIDC 토큰 sub의 저장소 부분 (owner@ownerId/repo@repoId)"
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "segments" {
  type = map(object({
    cidrs = list(string)
    tier  = string
  }))
}

variable "enable_nat" {
  type    = bool
  default = false
}

variable "enable_rds" {
  description = "sea 셀 RDS 인스턴스. 시간당 과금이라 필요할 때만 켬 (서브넷 그룹·파라미터 그룹·보안그룹은 항상 유지)"
  type        = bool
  default     = false
}

variable "enable_vpn" {
  description = "Site-to-Site VPN 연결. 시간당 과금이라 필요할 때만 켬"
  type        = bool
  default     = false
}

variable "classroom_public_ip" {
  description = "강의실 공인 IP. 공개 저장소라 secret.auto.tfvars(로컬)·GitHub Secret(CI)으로 넣음"
  type        = string
  sensitive   = true
}

variable "pvt_vpn_cidrs" {
  description = "VPN으로 AWS에 알려 줄 프라이빗 대역 (차량접속 제외)"
  type        = list(string)
}

variable "enable_vpn_test" {
  description = "VPN 확인용 테스트 EC2"
  type        = bool
  default     = false
}
