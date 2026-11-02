name_prefix           = "ccs"
external_network_name = "public"
dns_nameservers       = ["8.8.8.8", "1.1.1.1"]
image_name            = "ubuntu-24.04"
key_pair              = "ccs-key"

segments = {
  # .200~.250은 DHCP에서 빼 둠 → 11/4 MetalLB 풀
  vehicle = { cidr = "10.10.0.0/24", allocation_pool = { start = "10.10.0.10", end = "10.10.0.199" } }
  service = { cidr = "10.10.16.0/20" }
  data    = { cidr = "10.10.48.0/24" }
  mgmt    = { cidr = "10.10.56.0/24" }
}
