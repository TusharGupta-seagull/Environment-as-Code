

# ANSIBLE INVENTORY
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"

  content = templatefile(
    "${path.module}/ansible/templates/inventory.tpl",
    {
      bastion_public_ip = module.bastion_instances[0].public_ip,
      app_private_ips   = module.app_instances[*].private_ip,
      db_private_ips    = module.db_instances[*].private_ip,
      ssh_key_path      = local.ssh_key_path,
    }
  )
}

# SSH_CONFIG FOR SSH TO RESPECTIVE SERVER VIA JUMP SERVER
resource "local_file" "ssh_config" {
  filename = "${path.module}/ansible/ssh_config"

  content = templatefile(
    "${path.module}/ansible/templates/ssh_config.tpl",
    {
      bastion_public_ip = module.bastion_instances[0].public_ip,
      ssh_key_path      = local.ssh_key_path,
      app_private_ips   = module.app_instances[*].private_ip,
      db_private_ips    = module.db_instances[*].private_ip
    }
  )
}

# SLEEP FOR 90 seconds
resource "time_sleep" "wait_for_instances" {
  depends_on = [
    module.bastion_instances,
    module.app_instances,
    module.db_instances,
    local_file.ansible_inventory
  ]
  create_duration = "60s"
}


# RUN ANSIBLE PLAYBOOK
resource "null_resource" "run_ansible_playbook" {

  depends_on = [
    time_sleep.wait_for_instances
  ]

  triggers = {
    bastion_ip = module.bastion_instances[0].public_ip,
    app_ips    = join(",", module.app_instances[*].private_ip),
    db_ips     = join(",", module.db_instances[*].private_ip)
    inventory  = local_file.ansible_inventory.content
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible"
    command     = "ansible-playbook -i inventory.ini --vault-password-file vault_pass.txt playbook-main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_SSH_RETRIES       = "5"
      ANSIBLE_TIMEOUT           = "30"
    }
  }
}