## SERVICES — ASG-managed application services
## GOLDEN IMAGE (REQUIRED): the ASG launch template uses ONLY the golden image.
##   There is NO SSM / bare-AL2023 fallback for app instances — the build pipeline
##   must produce the baked application AMI and it must be set in `ami_id` below.

services = {
  app = {
    port          = 8080
    health_path   = "/"
    instance_type = "t3.micro"
    ami_id        = null # REQUIRED: replace with the golden image
    min_size      = 1
    max_size      = 3
    desired       = 1
    # IAM instance profile for the launch template (attach a role so instances can use AWS APIs)
    iam_instance_profile = null
  }
}
