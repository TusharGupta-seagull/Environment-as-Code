#1. NETWORK_CONFIG
network_config = {
  vpc = {
    cidr = "10.0.0.0/16"
  }

  subnets = {
    public = [
      {
        cidr       = "10.0.1.0/24"
        avail_zone = "ap-south-1a"
      },
      {
        cidr       = "10.0.2.0/24"
        avail_zone = "ap-south-1b"
      }
    ]

    private = [
      {
        cidr             = "10.0.10.0/24"
        enable_nat_route = true
        avail_zone       = "ap-south-1a"
      },
      {
        cidr             = "10.0.11.0/24"
        enable_nat_route = false
        avail_zone       = "ap-south-1b"
      }

    ]
  }

  settings = {
    map_public_ip_on_launch = {
      pub_sub  = true
      priv_sub = false
    }

    create_alb       = true
    allowed_ssh_cidr = "0.0.0.0/0"
  }
}
