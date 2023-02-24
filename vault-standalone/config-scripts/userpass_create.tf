resource "vault_auth_backend" "example_userpass" {
    type = "userpass"

}

resource "vault_generic_endpoint" "dummy_user" {
    depends_on = [vault_auth_backend.example_userpass]
    path = "auth/userpass/users/dummy_user"
    ignore_absent_fields = true

    data_json = <<EOT
  {
    "policies": ["superuser"],
    "password": "rotate!"
  }
  EOT
}
