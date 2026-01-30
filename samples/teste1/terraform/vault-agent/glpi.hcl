resource "local_file" "vault_agent_glpi" {
  content = <<EOF
pid_file = "/tmp/vault.pid"

auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/vault/role_id"
      secret_id_file_path = "/vault/secret_id"
    }
  }
}

template {
  source      = "/templates/db.conf.tpl"
  destination = "/secrets/db.conf"
}
EOF
  filename = "${path.module}/vault-agent/glpi.hcl"
}

