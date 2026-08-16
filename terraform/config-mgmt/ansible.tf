locals {
  ssh_key_path    = abspath("${path.module}/../../ansible/${var.key_name}.pem")
  inventory_path  = abspath("${path.module}/../../ansible/inventory.ini")
  ssh_config_path = abspath("${path.module}/../../ansible/ssh_config")
  playbook_path   = abspath("${path.module}/../../ansible/main.yaml")

  # Bastion-side locations (where the key + ssh_config are placed on the bastion)
  bastion_ssh_dir  = "/home/${var.ssh_user.bastion_user}/.ssh"
  bastion_key_path = "${local.bastion_ssh_dir}/${var.key_name}.pem"

  app_hosts = { for idx, ip in var.app_private_ips : "app-${idx}" => ip }
}

resource "local_file" "ansible_inventory" {
  filename = local.inventory_path

  content = templatefile(
    abspath("${path.module}/../../ansible/templates/inventory.tpl"),
    {
      bastion_public_ip = var.bastion_public_ip
      bastion_user      = var.ssh_user.bastion_user
      app_db_user       = var.ssh_user.app_db_user
      ssh_key_path      = local.ssh_key_path
      app_hosts         = local.app_hosts
    }
  )

  file_permission = "0644"
}

resource "local_file" "ssh_config" {
  filename = local.ssh_config_path

  content = templatefile(
    abspath("${path.module}/../../ansible/templates/ssh_config.tpl"),
    {
      bastion_public_ip = var.bastion_public_ip
      bastion_user      = var.ssh_user.bastion_user
      app_db_user       = var.ssh_user.app_db_user
      bastion_key_path  = local.bastion_key_path
      app_hosts         = local.app_hosts
    }
  )
  file_permission = "0644"
}

resource "time_sleep" "wait_for_instances" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.ssh_config
  ]
  create_duration = "${var.instance_wait_seconds}s"
}

resource "null_resource" "run_ansible_playbook" {

  depends_on = [time_sleep.wait_for_instances]

  triggers = {
    bastion_ip    = var.bastion_public_ip
    app_ips       = join(",", var.app_private_ips)
    inventory     = local_file.ansible_inventory.content
    ssh_config    = local_file.ssh_config.content
    key_name      = var.key_name
    playbook_hash = filesha256(local.playbook_path)
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "ansible-playbook -i ${local.inventory_path} -e 'ssh_key_src=${local.ssh_key_path}' -e 'ssh_key_name=${var.key_name}' -e 'ssh_config_src=${local.ssh_config_path}' -e 'rds_endpoint=${var.rds_endpoint}' -e 'rds_port=${var.rds_port}' -e 'rds_username=${var.rds_username}' ${local.playbook_path}"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_SSH_RETRIES       = "5"
      ANSIBLE_TIMEOUT           = "30"
      ANSIBLE_SSH_ARGS          = "-o ControlMaster=auto -o ControlPersist=60s"
    }
  }
}
