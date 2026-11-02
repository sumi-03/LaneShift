output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  description = "구간 이름 => AZ 순서대로 서브넷 ID 목록"
  value = {
    for seg, s in var.segments : seg => [for i in range(length(s.cidrs)) : aws_subnet.this["${seg}-${i}"].id]
  }
}

output "route_table_ids" {
  value = { for k, rt in aws_route_table.this : k => rt.id }
}
