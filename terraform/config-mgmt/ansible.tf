locals {
  ssh_key_path = abspath("${path.module}../../ansible/${var.key_name}.pem")

  application = {
    bastion_public_ip = var.application_instance_ips.bastion_public_ip
    app_private_ips   = var.application_instance_ips.app_private_ips
    db_private_ips    = var.application_instance_ips.db_private_ips
  }
}

resource "local_file" "ansible_inventory" {
  filename = abspath("${path.module}../../ansible/inventory.ini")

  content = templatefile(
    abspath("${path.module}/../../ansible/templates/inventory.tpl"),
    {
      bastion_public_ip = local.application.bastion_public_ip
      app_private_ips   = local.application.app_private_ips
      db_private_ips    = local.application.db_private_ips
      ssh_key_path      = local.ssh_key_path
      bastion_user      = var.ssh_user.bastion_user
      app_db_user       = var.ssh_user.app_db_user
    }
  )

  file_permission = "0644"
}

resource "local_file" "ssh_config" {
  filename = abspath("${path.module}/../../ansible/ssh_config")

  content = templatefile(
    abspath("${path.module}/../../ansible/templates/ssh_config.tpl"),
    {
      bastion_public_ip = local.application.bastion_public_ip
      ssh_key_path      = local.ssh_key_path
      app_private_ips   = local.application.app_private_ips
      db_private_ips    = local.application.db_private_ips
      bastion_user      = var.ssh_user.bastion_user
      app_db_user       = var.ssh_user.app_db_user
    }
  )
  file_permission = "0644"
}

resource "time_sleep" "wait_for_instances" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.ssh_config
  ]
  create_duration = "120s"
}

resource "null_resource" "run_ansible_playbook" {

  depends_on = [
  time_sleep.wait_for_instances]
  triggers = {
    bastion_ip = local.application.bastion_public_ip
    app_ips    = join(",", local.application.app_private_ips)
    db_ips     = join(",", local.application.db_private_ips)
    inventory  = local_file.ansible_inventory.content
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "ansible-playbook -i ../../ansible/inventory.ini --vault-password-file ../../ansible/vault_pass.txt ../../ansible/playbook-main.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_SSH_RETRIES       = "5"
      ANSIBLE_TIMEOUT           = "30"
      ANSIBLE_SSH_ARGS          = "-o ControlMaster=auto -o ControlPersist=60s"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Ansible provisioner destroyed'"
  }
}
