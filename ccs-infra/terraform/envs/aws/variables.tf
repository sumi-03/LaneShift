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
