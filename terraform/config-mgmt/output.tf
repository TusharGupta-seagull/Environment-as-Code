#Ansible output
output "ansible" {
  description = "Ansible configuration outputs"
  value = {
    inventory_file     = try(local_file.ansible_inventory.filename, null)
    ssh_config_file    = try(local_file.ssh_config.filename, null)
    ssh_key_path       = local.ssh_key_path
    bastion_connection = try("ssh -i ${local.ssh_key_path} ${var.ssh_user}@${local.application.bastion_public_ip}", null)
  }
  sensitive = true
}
