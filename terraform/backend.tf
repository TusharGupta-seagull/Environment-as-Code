terraform {
  backend "s3" {
    bucket       = "eac-terraform-state-seagull-989796"
    key          = "terraform/state/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true

    # Each Terraform workspace (dev, staging, prod) gets its own state file:
    #   env:<workspace>/terraform/state/terraform.tfstate
    workspace_key_prefix = "env:"
  }
}
