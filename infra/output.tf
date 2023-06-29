output subnet {
  value = scaleway_vpc_private_network.kapsule.ipv4_subnet[0].subnet
}
