variable "vault_address" {}

# identities
variable "vault_tf_role_id" {}
variable "vault_tf_secret_id" {}

variable "glpi_image" {
  default = "glpi/glpi:10.0.13"
}

variable "mariadb_image" {
  default = "mariadb:11"
}

