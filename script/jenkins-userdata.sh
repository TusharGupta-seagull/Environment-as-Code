#!/bin/bash

set -euo pipefail

exec > >(tee -a /var/log/jenkins-bootstrap.log) 2>&1

TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.15.6}"
JENKINS_REPO_URL="https://pkg.jenkins.io/rpm-stable/jenkins.repo"
JENKINS_KEY_URL="https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key"

log() { echo "[jenkins-bootstrap] $*"; }

log "Installing base tools (git, aws-cli, jq, unzip, wget, curl)"
dnf install -y git aws-cli jq unzip wget curl

log "Installing Java 21 (Amazon Corretto)"
dnf install -y java-21-amazon-corretto-devel

log "Adding Jenkins stable repository"
wget -O /etc/yum.repos.d/jenkins.repo "${JENKINS_REPO_URL}"
rpm --import "${JENKINS_KEY_URL}"
dnf upgrade -y

log "Installing Jenkins"
dnf install -y jenkins

log "Installing Terraform ${TERRAFORM_VERSION}"
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)  TF_ARCH="amd64" ;;
  aarch64) TF_ARCH="arm64" ;;
  *)       TF_ARCH="${ARCH}" ;;
esac
curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip" -o /tmp/terraform.zip
unzip -q -o /tmp/terraform.zip -d /usr/local/bin
rm -f /tmp/terraform.zip
terraform version

log "Installing Ansible (ansible-core)"
if ! dnf install -y ansible-core; then
  log "ansible-core not available in the dnf repos - installing via pip"
  python3 -m pip install --upgrade ansible-core
fi
ansible --version | head -1

log "Enabling and starting Jenkins"
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

log "Waiting for Jenkins to become reachable on port 8080"
for _ in $(seq 1 30); do
  if curl -fsS http://localhost:8080/login >/dev/null 2>&1; then
    log "Jenkins is up at http://localhost:8080"
    break
  fi
  sleep 10
done

log "Bootstrap complete."
log "Initial admin password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
log "Then: install suggested plugins and create the admin user."
log "Attach an IAM instance role so the Jenkinsfile can manage AWS resources"
log "(no static credentials are used)."
