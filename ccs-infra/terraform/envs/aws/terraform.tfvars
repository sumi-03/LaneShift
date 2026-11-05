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

# NAT는 EKS 노드가 이미지를 받는 데 필요 (11/4부터). 시간당 과금
enable_nat = false

# RDS는 11/12 sea 셀 배포부터 상시 필요. 시간당 과금
enable_rds = false

# Site-to-Site VPN (11/3). 시간당 과금
enable_vpn = true

# 프라이빗 서비스 · 데이터 · 관리 구간만 (차량접속 10.10.0.0/24 제외)
pvt_vpn_cidrs = ["10.10.16.0/20", "10.10.48.0/24", "10.10.56.0/24"]

# VPN 확인용 테스트 EC2 (11/3). 확인 후 false
enable_vpn_test = false

# EKS (11/4). 시간당 과금
enable_eks            = false
eks_api_allowed_cidrs = ["10.10.16.0/20", "10.10.56.0/24"] # k8s-pvt 노드, 관리 VM
