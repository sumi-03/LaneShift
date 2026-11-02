terraform {
  required_version = ">= 1.10"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket       = "laneshift-tfstate-847c1b"
    key          = "pvt/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "openstack" {
  cloud = "ccs"
}
