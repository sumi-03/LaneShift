module "vpc" {
  source = "../../modules/aws-vpc"

  name_prefix = var.name_prefix
  cidr        = var.vpc_cidr
  azs         = var.azs
  segments    = var.segments
  enable_nat  = var.enable_nat
}
