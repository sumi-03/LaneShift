locals {
  # "구간-AZ순번" => 서브넷 정보 (예: service-0, service-1)
  subnets = merge([
    for seg, s in var.segments : {
      for i, cidr in s.cidrs : "${seg}-${i}" => {
        segment = seg
        cidr    = cidr
        az      = var.azs[i]
        tier    = s.tier
      }
    }
  ]...)

  # NAT 게이트웨이를 둘 public 서브넷 (첫 번째 AZ)
  nat_subnet_key = sort([for k, s in local.subnets : k if s.tier == "public"])[0]
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "this" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name    = "${var.name_prefix}-${each.value.segment}-${substr(each.value.az, -1, 1)}"
    Segment = each.value.segment
    Tier    = each.value.tier
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

# 등급별 라우팅 테이블 3개
resource "aws_route_table" "this" {
  for_each = toset(["public", "private", "isolated"])
  vpc_id   = aws_vpc.this.id
  tags     = { Name = "${var.name_prefix}-rt-${each.key}" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.this["public"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  for_each       = local.subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.tier].id
}

# NAT 게이트웨이 (enable_nat = true일 때만)
resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}-nat" }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.this[local.nat_subnet_key].id
  tags          = { Name = "${var.name_prefix}-nat" }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.this["private"].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}
