#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Terraform environments ==="
cd "$ROOT/terraform"
terraform output 2>/dev/null || echo "Terraform has not been applied yet."

echo
echo "=== Ansible-managed services ==="
for service in nginx ssh nagios4; do
  if systemctl is-active --quiet "$service"; then
    printf "%-10s active\n" "$service"
  else
    printf "%-10s inactive\n" "$service"
  fi
done

echo
echo "=== Nagios configuration ==="
if command -v nagios4 >/dev/null 2>&1; then
  sudo nagios4 -v /etc/nagios4/nagios.cfg 2>&1 | tail -n 8
else
  echo "nagios4 is not installed."
fi

echo
echo "=== HTTP and SSH checks ==="
"$ROOT/scripts/health_check.sh" || true
