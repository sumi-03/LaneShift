output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}

output "rds_endpoint" {
  value = try(aws_db_instance.sea[0].endpoint, null)
}
