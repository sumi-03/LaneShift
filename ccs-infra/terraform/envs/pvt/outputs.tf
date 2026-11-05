output "network_ids" {
  value = module.network.network_ids
}

output "mgmt_test_vm_fixed_ips" {
  value = module.mgmt_test_vm.fixed_ips
}

output "mgmt_test_vm_floating_ip" {
  value = module.mgmt_test_vm.floating_ip
}

output "vpn_gw_fixed_ip" {
  value = module.vpn_gw.fixed_ips[0]
}

output "vpn_gw_floating_ip" {
  value = module.vpn_gw.floating_ip
}

output "k8s_cp_ip" {
  value = module.k8s_cp.fixed_ips[0]
}

output "k8s_worker_ips" {
  description = "워커별 [서비스 구간, 차량접속 구간]"
  value       = [for w in module.k8s_worker : w.fixed_ips]
}
