resource "docker_container" "traefik" {
  name  = "traefik"
  image = "traefik:v3.0"

  networks_advanced {
    name = docker_network.glpi_net.name
  }

  networks_advanced {
    name = docker_network.ztna_net.name
  }

  command = [
    "--entrypoints.websecure.address=:443",
    "--entrypoints.websecure.http.tls=true",
    "--entrypoints.websecure.http.tls.options=ztls@file",
    "--serversTransport.rootCAs=/etc/ssl/internal-ca.pem"
  ]

  read_only = true
  cap_drop  = ["ALL"]
}

