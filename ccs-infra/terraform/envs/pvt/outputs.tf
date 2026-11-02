output "network_ids" {
  value = module.network.network_ids
}

output "mgmt_test_vm_fixed_ips" {
  value = module.mgmt_test_vm.fixed_ips
}

output "mgmt_test_vm_floating_ip" {
  value = module.mgmt_test_vm.floating_ip
}
