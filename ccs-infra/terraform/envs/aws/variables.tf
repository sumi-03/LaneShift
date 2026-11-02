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
