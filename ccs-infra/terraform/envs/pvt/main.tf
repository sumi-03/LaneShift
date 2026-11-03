module "network" {
  source = "../../modules/os-network"

  name_prefix           = var.name_prefix
  external_network_name = var.external_network_name
  dns_nameservers       = var.dns_nameservers
  segments              = var.segments
}

# 임시: 관리 구간 SSH·ICMP. W5(11/23)에 구간별 보안그룹으로 교체
# floating IP 대역(172.16.0.0/24)은 호스트 안에만 있어 강의실 밖에서는 닿지 않음
resource "openstack_networking_secgroup_v2" "mgmt_ssh" {
  name        = "${var.name_prefix}-mgmt-ssh"
  description = "mgmt SSH and ICMP (temporary until W5)"
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_ssh" {
  security_group_id = openstack_networking_secgroup_v2.mgmt_ssh.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_icmp" {
  security_group_id = openstack_networking_secgroup_v2.mgmt_ssh.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}

module "mgmt_test_vm" {
  source = "../../modules/os-vm"

  name        = "${var.name_prefix}-mgmt-test"
  image_name  = var.image_name
  flavor_name = "ccs.small"
  key_pair    = var.key_pair
  networks = [{
    network_id = module.network.network_ids["mgmt"]
    subnet_id  = module.network.subnet_ids["mgmt"]
  }]
  security_group_ids = [openstack_networking_secgroup_v2.mgmt_ssh.id]
  floating_ip_pool   = var.external_network_name

  # 라우터 인터페이스가 붙기 전에 floating IP를 만들면 실패하므로 망 전체를 기다림
  depends_on = [module.network]
}

# 11/3 Site-to-Site VPN 게이트웨이 (strongSwan). 관리 구간에서 floating IP로 AWS에 먼저 연결을 건다

# 프라이빗 구간 → AWS로 가는 패킷이 이 VM 포트로 들어오도록 허용
resource "openstack_networking_secgroup_v2" "vpn_gw" {
  name        = "${var.name_prefix}-vpn-gw"
  description = "VPN gateway: traffic from pvt segments to AWS"
}

resource "openstack_networking_secgroup_rule_v2" "vpn_gw_from_pvt" {
  for_each          = toset(var.vpn_local_cidrs)
  security_group_id = openstack_networking_secgroup_v2.vpn_gw.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value
}

module "vpn_gw" {
  source = "../../modules/os-vm"

  name        = "${var.name_prefix}-vpn-gw"
  image_name  = var.image_name
  flavor_name = "ccs.small"
  key_pair    = var.key_pair
  networks = [{
    network_id = module.network.network_ids["mgmt"]
    subnet_id  = module.network.subnet_ids["mgmt"]
  }]
  security_group_ids    = [openstack_networking_secgroup_v2.mgmt_ssh.id, openstack_networking_secgroup_v2.vpn_gw.id]
  floating_ip_pool      = var.external_network_name
  allowed_address_pairs = [var.aws_vpc_cidr] # 없으면 Neutron이 10.20.x 패킷을 버림

  depends_on = [module.network]
}

# OpenStack 라우터: AWS 대역은 VPN VM으로
resource "openstack_networking_router_route_v2" "to_aws" {
  router_id        = module.network.router_id
  destination_cidr = var.aws_vpc_cidr
  next_hop         = module.vpn_gw.fixed_ips[0]
}
