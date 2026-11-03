output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "rds_endpoint" {
  value = try(aws_db_instance.sea[0].endpoint, null)
}

output "vpn_test_private_ip" {
  value = try(aws_instance.vpn_test[0].private_ip, null)
}
