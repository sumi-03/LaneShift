output "id" {
  value = openstack_compute_instance_v2.this.id
}

output "fixed_ips" {
  value = [for p in openstack_networking_port_v2.this : p.all_fixed_ips[0]]
}

output "floating_ip" {
  value = try(openstack_networking_floatingip_v2.this[0].address, null)
}
