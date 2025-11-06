#!/bin/bash

sudo yum update -y
sudo yum upgrade -y

# Disable password SSH login (optional — for stricter security)
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

