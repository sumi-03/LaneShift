variable "name_prefix" {
  type = string
}

variable "external_network_name" {
  type = string
}

variable "dns_nameservers" {
  type = list(string)
}

variable "segments" {
  type = map(object({
    cidr = string
    allocation_pool = optional(object({
      start = string
      end   = string
    }))
  }))
}

variable "image_name" {
  type = string
}

variable "key_pair" {
  type = string
}
