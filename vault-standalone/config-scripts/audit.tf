resource "vault_audit" "example_audit_log" {
  type = "file"
  options = {
    file_path = "/vault/audit.log"
    description = "Vault audit log"
  }
}
