# 11/3 Site-to-Site VPN: 강의실 프라이빗 사이트 ↔ AWS VPC (10.20.0.0/16)
# 강의실 망은 들어오는 연결을 막으므로 터널은 강의실 쪽이 먼저 연다 → 시작 옵션은 기본값 유지
# VPN 연결은 시간당 과금이라 enable_vpn으로 켜고 끈다. CGW·VGW는 과금이 없어 항상 둔다

resource "aws_customer_gateway" "classroom" {
  bgp_asn    = 65010 # 정적 라우팅이라 쓰이지 않지만 필수 값
  ip_address = var.classroom_public_ip
  type       = "ipsec.1"
  tags       = { Name = "${var.name_prefix}-cgw-classroom" }
}

resource "aws_vpn_gateway" "this" {
  vpc_id = module.vpc.vpc_id
  tags   = { Name = "${var.name_prefix}-vgw" }
}

resource "aws_vpn_connection" "pvt" {
  count = var.enable_vpn ? 1 : 0

  customer_gateway_id = aws_customer_gateway.classroom.id
  vpn_gateway_id      = aws_vpn_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  # IKEv2 · AES256 · SHA256 · DH14 하나로 고정
  tunnel1_ike_versions                 = ["ikev2"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers      = [14]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers      = [14]

  tunnel2_ike_versions                 = ["ikev2"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase1_dh_group_numbers      = [14]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-256"]
  tunnel2_phase2_dh_group_numbers      = [14]

  tags = { Name = "${var.name_prefix}-vpn-pvt" }
}

# AWS → 프라이빗 경로: 서비스·데이터·관리만 (차량접속 10.10.0.0/24 제외)
resource "aws_vpn_connection_route" "pvt" {
  for_each               = var.enable_vpn ? toset(var.pvt_vpn_cidrs) : toset([])
  vpn_connection_id      = aws_vpn_connection.pvt[0].id
  destination_cidr_block = each.value
}

# 위 경로를 라우팅 테이블에 자동 반영. public(차량접속) 테이블은 제외
resource "aws_vpn_gateway_route_propagation" "this" {
  for_each       = toset(["private", "isolated"])
  vpn_gateway_id = aws_vpn_gateway.this.id
  route_table_id = module.vpc.route_table_ids[each.key]
}
