# GitHub OIDC 토큰의 sub에 들어오는 형식 그대로 (계정@계정ID/저장소@저장소ID)
github_repo = "sumi-03@100473912/LaneShift@1434416811"

name_prefix = "ccs"
vpc_cidr    = "10.20.0.0/16"
azs         = ["ap-northeast-2a", "ap-northeast-2c"]

segments = {
  vehicle = { cidrs = ["10.20.0.0/24", "10.20.1.0/24"], tier = "public" }
  service = { cidrs = ["10.20.16.0/20", "10.20.32.0/20"], tier = "private" }
  data    = { cidrs = ["10.20.48.0/24", "10.20.49.0/24"], tier = "isolated" }
  mgmt    = { cidrs = ["10.20.56.0/24", "10.20.57.0/24"], tier = "private" }
}

# NAT는 11/5 EKS부터 필요. 시간당 과금
enable_nat = false
