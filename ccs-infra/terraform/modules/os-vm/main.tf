terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

# 포트를 따로 만들어 보안그룹·고정 서브넷을 포트 단위로 관리
resource "openstack_networking_port_v2" "this" {
  count              = length(var.networks)
  name               = "${var.name}-port${count.index}"
  network_id         = var.networks[count.index].network_id
  security_group_ids = var.security_group_ids

  fixed_ip {
    subnet_id = var.networks[count.index].subnet_id
  }

  # 첫 번째 포트에만: 자기 IP가 아닌 대역도 통과 (VPN VM처럼 남의 패킷을 전달하는 VM용)
  dynamic "allowed_address_pairs" {
    for_each = count.index == 0 ? var.allowed_address_pairs : []
    content {
      ip_address = allowed_address_pairs.value
    }
  }
}

resource "openstack_compute_instance_v2" "this" {
  name        = var.name
  image_id    = data.openstack_images_image_v2.this.id
  flavor_name = var.flavor_name
  key_pair    = var.key_pair
  user_data   = var.user_data

  dynamic "network" {
    for_each = openstack_networking_port_v2.this
    content {
      port = network.value.id
    }
  }
}

resource "openstack_networking_floatingip_v2" "this" {
  count   = var.floating_ip_pool == null ? 0 : 1
  pool    = var.floating_ip_pool
  port_id = openstack_networking_port_v2.this[0].id
}
