# 11/3 VPN 확인용 테스트 EC2 (서비스 구간). 확인이 끝나면 enable_vpn_test = false로 삭제

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "vpn_test" {
  count       = var.enable_vpn_test ? 1 : 0
  name        = "${var.name_prefix}-vpn-test"
  description = "VPN test: ICMP from pvt mgmt"
  vpc_id      = module.vpc.vpc_id
  tags        = { Name = "${var.name_prefix}-vpn-test", Segment = "service" }
}

# 프라이빗 관리 구간 → 이 EC2로 ping 허용
resource "aws_vpc_security_group_ingress_rule" "vpn_test_icmp" {
  count             = var.enable_vpn_test ? 1 : 0
  security_group_id = aws_security_group.vpn_test[0].id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = "10.10.56.0/24"
}

# Terraform으로 만든 보안그룹은 나가는 규칙이 비어 있어서 직접 열어 줌 (EC2 → 프라이빗 ping용)
resource "aws_vpc_security_group_egress_rule" "vpn_test_all" {
  count             = var.enable_vpn_test ? 1 : 0
  security_group_id = aws_security_group.vpn_test[0].id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "vpn_test" {
  count                  = var.enable_vpn_test ? 1 : 0
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.subnet_ids["service"][0]
  vpc_security_group_ids = [aws_security_group.vpn_test[0].id]

  # 반대 방향 확인: 부팅 후 10분 동안 프라이빗 테스트 VM에 ping을 보냄 (VM 쪽에서 tcpdump로 확인)
  user_data = <<-EOF
    #!/bin/bash
    for i in $(seq 1 60); do ping -c 1 -W 2 10.10.56.195; sleep 10; done
  EOF

  tags = { Name = "${var.name_prefix}-vpn-test", Segment = "service" }
}
