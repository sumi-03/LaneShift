# 11/4 k8s-pvt: cp 1 + worker N (서비스 구간). 워커는 차량접속 NIC 추가 (MetalLB 진입)

# 노드끼리 통신 + 관리 구간에서 SSH·Kubespray. W5(11/23)에 구간별 보안그룹으로 교체
resource "openstack_networking_secgroup_v2" "k8s_node" {
  name        = "${var.name_prefix}-k8s-node"
  description = "k8s-pvt nodes (temporary until W5)"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_node_from" {
  for_each          = toset([var.segments["service"].cidr, var.segments["mgmt"].cidr])
  security_group_id = openstack_networking_secgroup_v2.k8s_node.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value
}

# 워커 차량접속 NIC: 차량접속 구간과 호스트(외부망)에서 MetalLB IP로 들어오는 접속
resource "openstack_networking_secgroup_v2" "k8s_vehicle" {
  name        = "${var.name_prefix}-k8s-vehicle"
  description = "k8s-pvt worker vehicle NIC (temporary until W5)"
}

resource "openstack_networking_secgroup_rule_v2" "k8s_vehicle_from" {
  for_each          = toset([var.segments["vehicle"].cidr, "172.16.0.0/24"])
  security_group_id = openstack_networking_secgroup_v2.k8s_vehicle.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value
}

module "k8s_cp" {
  source = "../../modules/os-vm"

  name        = "${var.name_prefix}-k8s-cp1"
  image_name  = var.image_name
  flavor_name = "ccs.small"
  key_pair    = var.key_pair
  networks = [{
    network_id = module.network.network_ids["service"]
    subnet_id  = module.network.subnet_ids["service"]
  }]
  security_group_ids = [openstack_networking_secgroup_v2.k8s_node.id]

  depends_on = [module.network]
}

module "k8s_worker" {
  count  = var.k8s_worker_count
  source = "../../modules/os-vm"

  name        = "${var.name_prefix}-k8s-w${count.index + 1}"
  image_name  = var.image_name
  flavor_name = "ccs.medium"
  key_pair    = var.key_pair
  networks = [
    {
      network_id = module.network.network_ids["service"]
      subnet_id  = module.network.subnet_ids["service"]
    },
    {
      network_id            = module.network.network_ids["vehicle"]
      subnet_id             = module.network.subnet_ids["vehicle"]
      security_group_ids    = [openstack_networking_secgroup_v2.k8s_vehicle.id]
      allowed_address_pairs = [var.metallb_pool_cidr] # 없으면 Neutron이 MetalLB IP 패킷을 버림
    },
  ]
  security_group_ids = [openstack_networking_secgroup_v2.k8s_node.id]
  user_data          = file("${path.module}/cloud-init/k8s-worker.yaml")

  depends_on = [module.network]
}
