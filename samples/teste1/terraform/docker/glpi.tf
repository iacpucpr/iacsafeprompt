resource "docker_container" "glpi" {
  name  = "glpi"
  image = var.glpi_image
  user  = "1000:1000"

  read_only = true

  networks_advanced {
    name = docker_network.glpi_net.name
  }

  networks_advanced {
    name = docker_network.db_net.name
  }

  volumes {
    volume_name    = docker_volume.glpi_data.name
    container_path = "/var/www/html"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.glpi_secrets.name
    container_path = "/run/secrets"
    read_only      = true
  }

  cap_drop = ["ALL"]

  depends_on = [docker_container.mariadb]
}

