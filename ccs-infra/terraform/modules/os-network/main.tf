terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

# 외부망(public)은 관리자가 만든 것이라 참조만 한다
data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name
  external = true
}

resource "openstack_networking_network_v2" "this" {
  for_each       = var.segments
  name           = "${var.name_prefix}-${each.key}"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "this" {
  for_each        = var.segments
  name            = "${var.name_prefix}-${each.key}"
  network_id      = openstack_networking_network_v2.this[each.key].id
  cidr            = each.value.cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers

  dynamic "allocation_pool" {
    for_each = each.value.allocation_pool == null ? [] : [each.value.allocation_pool]
    content {
      start = allocation_pool.value.start
      end   = allocation_pool.value.end
    }
  }
}

resource "openstack_networking_router_v2" "this" {
  name                = "${var.name_prefix}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "this" {
  for_each  = var.segments
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this[each.key].id
}
