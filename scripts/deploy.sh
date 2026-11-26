#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT/terraform"
ANSIBLE_DIR="$ROOT/ansible"
ENVIRONMENT="${1:-development}"

case "$ENVIRONMENT" in
  development) VAR_FILE="dev.tfvars" ;;
  testing) VAR_FILE="test.tfvars" ;;
  production) VAR_FILE="prod.tfvars" ;;
  *)
    echo "Usage: $0 [development|testing|production]" >&2
    exit 1
    ;;
esac

cd "$TF_DIR"
terraform fmt -check
terraform validate
terraform apply -auto-approve "-var-file=$VAR_FILE"

cd "$ANSIBLE_DIR"
ansible-playbook -i inventory/hosts.ini site.yml

sudo nginx -t
sudo nagios4 -v /etc/nagios4/nagios.cfg
sudo systemctl is-active nginx
sudo systemctl is-active ssh
sudo systemctl is-active nagios4

"$ROOT/scripts/health_check.sh"
