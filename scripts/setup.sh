#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT/terraform"

if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "Detected Ubuntu WSL environment."
else
  echo "WARNING: This project is designed for Ubuntu 22.04 WSL."
fi

for command_name in terraform ansible-playbook sudo; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing prerequisite: $command_name" >&2
    exit 1
  fi
done

cd "$TF_DIR"
terraform init
terraform fmt -check
terraform validate

echo "Setup complete. Inventory and environment resources are initialized."
