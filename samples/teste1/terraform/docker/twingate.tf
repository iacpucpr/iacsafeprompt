resource "docker_container" "twingate" {
  name  = "twingate-glpi"
  image = "twingate/connector:latest"

  networks_advanced {
    name = docker_network.ztna_net.name
  }

  env = [
    "TWINGATE_NETWORK=${var.twingate_network}",
    "TWINGATE_ACCESS_TOKEN=${var.twingate_access_token}",
    "TWINGATE_REFRESH_TOKEN=${var.twingate_refresh_token}"
  ]

  read_only = true
  cap_drop  = ["ALL"]
}

