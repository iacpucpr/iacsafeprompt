terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "docker" {}

# Terraform-only identity
provider "vault" {
  alias   = "terraform"
  address = var.vault_address

  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_tf_role_id
      secret_id = var.vault_tf_secret_id
    }
  }
}

