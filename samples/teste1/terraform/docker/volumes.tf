resource "docker_volume" "glpi_secrets" {
  name = "glpi_secrets"
  driver_opts = {
    type   = "tmpfs"
    device = "tmpfs"
    o      = "size=64m,uid=1000,gid=1000"
  }
}

