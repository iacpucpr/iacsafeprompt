resource "docker_container" "mariadb" {
  name  = "mariadb"
  image = var.mariadb_image
  user  = "999:999"

  read_only = true

  networks_advanced {
    name = docker_network.db_net.name
  }

  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/mysql"
  }

  cap_drop = ["ALL"]
}

