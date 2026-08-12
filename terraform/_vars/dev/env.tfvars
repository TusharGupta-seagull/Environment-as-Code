## 1. PROJECT_CONFIG

# --------------------------------------------------------------------------------

# 1. PROJECT_CONFIG
project_config = {
  project_name = "eac"
  env_name     = "dev"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "EAC"
    Owner       = "SgAlpha"
  }
}

# For Ansible - runs the bastion provisioning playbook after apply
# (requires ansible-playbook on the machine running terraform apply)
go_ansible = true
