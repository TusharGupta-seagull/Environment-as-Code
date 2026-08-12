# Environment-as-Code (EAC)

Terraform + Ansible setup for the EAC project. Terraform creates the AWS infrastructure, Ansible configures the bastion host, and a Jenkins pipeline runs terraform end to end.

## What it creates

Everything stays in `ap-south-1` (Mumbai):

- VPC with public/private subnets, internet gateway and NAT gateway
- Security groups for the ALB, bastion, app instances and RDS
- A bastion EC2 instance for SSH access
- Auto scaling groups for the app services, launched from a golden AMI
- An ALB in front of the services
- RDS MariaDB (only when `rds_config.create_rds` is `true`)
- An SSH key pair, generated on first apply unless you already have one
- The RDS password, stored in SSM Parameter Store — never in the repo

When `go_ansible` is `true` (it is in dev), an Ansible playbook runs after apply and provisions the bastion: installs some tools, copies the SSH key and config over, and adds an `rds-mysql` helper so you can reach the database from the bastion.

## Layout

| Path | Contents |
|---|---|
| `Jenkinsfile` | The pipeline: init → plan → apply → destroy |
| `terraform/` | All the Terraform code |
| `terraform/_modules/` | Reusable modules (vpc, sg, ec2, asg, alb, rds, ami) |
| `terraform/application/` | Bastion, ASG services and ALB wiring |
| `terraform/network/` | VPC and security groups |
| `terraform/database/` | RDS |
| `terraform/config-mgmt/` | Generates the Ansible inventory/ssh config and runs the playbook |
| `terraform/_vars/dev/` | Values for the dev environment |
| `terraform/backend.tf` | S3 remote state |
| `ansible/` | The playbook and templates |
| `script/jenkins-userdata.sh` | Bootstraps a Jenkins server on a fresh EC2 |

## Prerequisites

- **A Jenkins server:** `script/jenkins-userdata.sh` installs Jenkins, Terraform and Ansible on Amazon Linux 2023 — run it by hand or pass it as user-data. Give the instance an IAM role with enough permissions to manage the resources; there are no static AWS keys involved.
- **The S3 state bucket:** Replace the bucket name in the `backend.tf` file with required s3 bucket name.
- **A golden AMI for the app services:** The ASG launch template uses `services.app.ami_id` and nothing else, so set it in `terraform/_vars/dev/services.tfvars` or terraform fails validation. The bastion is exempt — it always uses Amazon Linux 2023.
- **An RDS password** if you're using the database. See below — the repo never contains it.

## Running via Jenkins

One-time setup:

1. Install Jenkins and the plugins
2. Create a piple with Script Path: `Jenkinsfile`
4. Optional: set `DB_PASSWORD` in Jenkins if you want to supply the database password yourself.

Then just **Build with Parameters**. The only parameter is `ENVIRONMENT` (defaults to `dev`). What the stages do:

- **Checkout / Init / Workspace** — pull the code, init providers and the S3 backend, select or create a workspace named after the environment. Each workspace gets its own state file.
- **Prepare DB Password** — decides where the password comes from (see below).
- **Validate / Plan** — shows what will change. Read this before approving anything.
- **Apply** — needs manual approval in the UI.
- **Destroy** — also manual, only runs if you trigger it.

## Running manually

If you'd rather run terraform yourself (on the agent or locally):

```bash
cd terraform
terraform init
terraform workspace select dev 2>/dev/null || terraform workspace new dev

terraform plan \
  -var-file=_vars/dev/env.tfvars \
  -var-file=_vars/dev/network.tfvars \
  -var-file=_vars/dev/compute.tfvars \
  -var-file=_vars/dev/database.tfvars \
  -var-file=_vars/dev/services.tfvars

# then apply with the same flags
```

**Important for the manual path:** with `go_ansible = true`, the machine running apply needs `ansible-playbook`. Set `go_ansible = false` if you're testing locally without Ansible.

Destroy works the same way, with `terraform destroy` and the same `-var-file` flags.

## Configuration

Environment settings live in `terraform/_vars/<env>/`. For dev:

- `env.tfvars` — project name, tags, `go_ansible`
- `network.tfvars` — VPC CIDR, subnets/AZs, ALB toggle, allowed SSH CIDR
- `compute.tfvars` — bastion size, ALB settings, key name
- `database.tfvars` — RDS engine/size/username
- `services.tfvars` — services: port, health check path, ASG min/max/desired, and the required golden `ami_id`

Common tweaks: scale a service via `min_size`/`max_size`/`desired` in `services.tfvars`, enable the DB with `create_rds = true`, skip Ansible with `go_ansible = false`, or use your own key pair via `ssh_key_pair_name` + `ssh_private_key_path`.

## Database password

One of these, in order:

1. `TF_VAR_db_password` env var on the Jenkins agent (export it, or fetch from Vault)
2. `db_password_ssm_parameter` — name of an existing SSM SecureString parameter
3. Terraform generates a random password on first apply and stores it in SSM at `/eac/dev/db/password`

## Connecting to the bastion

```bash
ssh -i ansible/eac-dev-key.pem ec2-user@<bastion-public-ip>
```

The key is generated on first apply and saved to `ansible/eac-dev-key.pem` (git-ignored). Username is `ec2-user`. Grab the public IP from the `deployment_summary` terraform output. If you set `ssh_key_pair_name`, use that key instead.
