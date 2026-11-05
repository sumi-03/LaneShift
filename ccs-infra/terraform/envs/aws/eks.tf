# 11/4 sea 리전 EKS: private 엔드포인트만, 관리형 노드(서비스 서브넷). 시간당 과금이라 enable_eks로 켜고 끔
module "eks" {
  count   = var.enable_eks ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.29"

  name               = "${var.name_prefix}-eks-sea"
  kubernetes_version = "1.36"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids["service"]

  # API는 VPC 안과 VPN 너머에서만
  endpoint_public_access  = false
  endpoint_private_access = true

  # 강의실 쪽(k8s-pvt 노드, 관리 VM)에서 VPN으로 API(443) 접속
  security_group_additional_rules = {
    api_from_pvt = {
      description = "k8s-pvt nodes and mgmt VM via VPN"
      from_port   = 443
      to_port     = 443
      cidr_blocks = var.eks_api_allowed_cidrs
    }
  }

  # terraform을 실행한 IAM 사용자(laneshift-admin)를 클러스터 관리자로
  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.eks_node_instance_types
      min_size       = 0
      max_size       = 3
      desired_size   = var.eks_node_desired # 처음 만들 때만 적용됨
    }
  }

  # 학습 환경 비용 절감: 컨트롤 플레인 로그·KMS 키 만들지 않음 (Secret은 AWS 기본 키로 암호화)
  enabled_log_types           = []
  create_cloudwatch_log_group = false
  create_kms_key              = false
  encryption_config           = null
}
