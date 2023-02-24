resource "vault_policy" "superuser" {
    name = "superuser"
    policy = file("./superuser.hcl")
}
