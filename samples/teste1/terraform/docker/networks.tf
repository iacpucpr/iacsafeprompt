resource "docker_network" "glpi_net" {
  name     = "glpi_net"
  internal = true
}

resource "docker_network" "db_net" {
  name     = "db_net"
  internal = true
}

resource "docker_network" "ztna_net" {
  name     = "ztna_net"
  internal = true
}

