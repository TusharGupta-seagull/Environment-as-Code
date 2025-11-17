#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

args=""
for file in "$PROJECT_ROOT/_vars/dev/"*.tfvars; do
  args="$args -var-file=$file"
done

cd "$PROJECT_ROOT"

echo "Running: terraform plan $args"

terraform apply $args --auto-approve
