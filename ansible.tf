# Root Module - ansible.tf

locals {
  ssh_key_path = "${path.module}/ansible/${var.key_name}.pem"
}

# ANSIBLE INVENTORY
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"

  content = templatefile("${path.module}/ansible/templates/inventory.tpl",
    {
      bastion_public_ip = module.bastion_instances[0].public_ip,
      app_private_ips   = module.app_instances[*].private_ip,
      db_private_ips    = module.db_instances[*].private_ip,
      ssh_key_path      = local.ssh_key_path,
      bastion_user      = var.ssh_user.bastion_user,
      app_db_user       = var.ssh_user.app_db_user
    }
  )

  file_permission = "0644"

  depends_on = [
    module.bastion_instances,
    module.app_instances,
    module.db_instances
  ]
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
      db_private_ips    = module.db_instances[*].private_ip,
      bastion_user      = var.ssh_user.bastion_user,
      app_db_user       = var.ssh_user.app_db_user
    }
  )
  file_permission = "0644"
}

# Wait for instance to be ready
resource "time_sleep" "wait_for_instances" {
  depends_on = [
    module.bastion_instances,
    module.app_instances,
    module.db_instances,
    module.alb,
    local_file.ansible_inventory,
    local_file.ssh_config
  ]
  create_duration = "120s"
}

# Test SSH connectivity to bastion
resource "null_resource" "test_ssh_connectivity" {
  depends_on = [time_sleep.wait_for_instances]

  triggers = {
    bastion_ip = module.bastion_instances[0].public_ip
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Testing SSH to bastion at ${module.bastion_instances[0].public_ip}..."
      max_retries=5
      count=0
      until ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ${local.ssh_key_path} ${var.ssh_user.bastion_user}@${module.bastion_instances[0].public_ip} 'echo "Bastion SSH successful!"'; do
        count=$((count+1))
        if [ $count -ge $max_retries ]; then
          echo "SSH failed after $max_retries attempts"
          exit 1
        fi
        echo "SSH attempt $count failed, retrying in 10 seconds..."
        sleep 10
      done
      echo "SSH test completed successfully"
    EOT
  }
}

# RUN ANSIBLE PLAYBOOK
resource "null_resource" "run_ansible_playbook" {

  depends_on = [
    time_sleep.wait_for_instances,
    null_resource.test_ssh_connectivity,
    module.alb
  ]

  triggers = {
    bastion_ip = module.bastion_instances[0].public_ip,
    app_ips    = join(",", module.app_instances[*].private_ip),
    db_ips     = join(",", module.db_instances[*].private_ip),
    inventory  = local_file.ansible_inventory.content
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "ansible-playbook -i ansible/inventory.ini --vault-password-file ansible/vault_pass.txt ansible/playbook-main.yml"
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
