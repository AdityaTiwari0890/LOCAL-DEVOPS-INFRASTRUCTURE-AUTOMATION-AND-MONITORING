#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

cd "$ROOT/terraform"
terraform destroy -auto-approve "-var-file=$VAR_FILE"

echo "Terraform-managed project resources destroyed."
echo "System packages and unrelated files were not removed."
