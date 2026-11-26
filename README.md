# Local DevOps Infrastructure Automation & Monitoring System

A terminal-first local infrastructure lab for Ubuntu 22.04 LTS WSL. Terraform models
three logical environments, Ansible configures and validates the host, and Nagios
monitors HTTP, SSH, CPU, disk, processes, and localhost availability. It does not
use cloud infrastructure, containers, virtual machines, databases, or GUI tools.

## Architecture

| Environment | Port | Application directory |
|---|---:|---|
| Development | 8081 | `/var/www/local-devops/development` |
| Testing | 8082 | `/var/www/local-devops/testing` |
| Production | 8083 | `/var/www/local-devops/production` |

All environments share one Ubuntu/WSL host and separate Nginx server blocks.
Terraform creates directories/configuration, Ansible performs package and service
configuration, and Nagios schedules recurring local checks.

## Technology responsibilities

- **Terraform:** local state and managed project directories, metadata, inventory
  configuration, environment variables, and outputs.
- **Ansible:** package installation, users, directories, Nginx server blocks,
  HTML pages, SSH, Nagios, validation, and idempotent handlers.
- **Nginx:** localhost HTTP service on ports 8081, 8082, and 8083.
- **Nagios Core:** host and service monitoring using Ubuntu Nagios plugins.
- **Ubuntu 22.04 WSL:** the only operating environment; OpenSSH and systemd services
  must be available inside WSL.

## Folder structure

```text
terraform/                 Terraform local-provider resources and tfvars
ansible/                   Ansible project
  inventory/               localhost inventory
  roles/nginx/             Nginx and SSH configuration
  roles/monitoring/        Nagios configuration
  roles/users/             Local application user/directories
scripts/                   setup, deploy, health, status, destroy automation
docs/                      detailed architecture and operations guides
```

## Prerequisites

- Ubuntu 22.04 LTS running in WSL 2
- `sudo`, `curl`, `bash`, `systemctl`
- Terraform 1.5 or newer
- Ansible 2.14 or newer
- Network access to Ubuntu package repositories
- WSL distribution with systemd enabled

Enable systemd in `/etc/wsl.conf`:

```ini
[boot]
systemd=true
```

Then in Windows PowerShell: `wsl --shutdown`, and reopen Ubuntu.

For Ansible and Nagios/Nginx packages:

```bash
sudo apt update
sudo apt install -y ansible terraform openssh-server nginx nagios3 nagios-plugins
```

Package availability and naming can differ slightly across Ubuntu mirrors. If
Terraform is not in the Ubuntu repository, install the official HashiCorp package
following HashiCorp's Ubuntu instructions.

## Complete workflow

```bash
cd /path/to/terraform-ansible-static
chmod +x scripts/*.sh
./scripts/setup.sh
./scripts/deploy.sh development
./scripts/health_check.sh
./scripts/status.sh
```

Replace `development` with `testing` or `production` only as needed. Terraform
creates all three environments regardless of the selected tfvars file; the tfvars
selection identifies the currently selected environment.

## Terraform workflow

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
terraform output
terraform destroy -var-file=dev.tfvars
```

State is maintained in `terraform/terraform.tfstate`. Resources use the official
`hashicorp/local` provider and `local_file`. No cloud provider is installed or used.

## Ansible workflow

```bash
cd ansible
ansible-playbook --syntax-check -i inventory/hosts.ini site.yml
ansible-playbook -i inventory/hosts.ini site.yml
ansible localhost -i inventory/hosts.ini -m ping
```

Every deployment is repeatable. Nginx and Nagios handlers validate configuration
before reloading/restarting services.

## Nagios workflow

The custom configuration is `/etc/nagios3/conf.d/localhost-localdevops.cfg`.
Validation and restart:

```bash
sudo nagios3 -v /etc/nagios3/nagios.cfg
sudo systemctl restart nagios3
sudo systemctl status nagios3 --no-pager
```

Plugin checks can be run directly:

```bash
/usr/lib/nagios/plugins/check_http -p 8081 -H 127.0.0.1
/usr/lib/nagios/plugins/check_http -p 8082 -H 127.0.0.1
/usr/lib/nagios/plugins/check_http -p 8083 -H 127.0.0.1
/usr/lib/nagios/plugins/check_ssh -p 22 127.0.0.1
/usr/lib/nagios/plugins/check_ping -w 100.0,20% -c 200.0,40% 127.0.0.1
/usr/lib/nagios/plugins/check_load -w 4.0,3.0,2.0 -c 6.0,5.0,4.0
/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
/usr/lib/nagios/plugins/check_procs -w 250 -c 400
```

## Failure and recovery testing

### Nginx failure

1. `sudo systemctl stop nginx`
2. `./scripts/health_check.sh` — endpoints should report CRITICAL
3. Run a Nagios scheduling check and wait for a check cycle. In the Nagios web UI
   or status file, HTTP services should become CRITICAL.
4. `sudo systemctl start nginx`
5. Wait for the next cycle; `./scripts/health_check.sh` and Nagios should return OK.

### SSH failure

1. `sudo systemctl stop ssh`
2. `/usr/lib/nagios/plugins/check_ssh -p 22 127.0.0.1`
3. Wait for Nagios; the SSH service becomes CRITICAL.
4. `sudo systemctl start ssh`
5. Re-run the plugin and wait for Nagios recovery.

Never run these tests against a remote or production machine.

## Troubleshooting

- **Port in use:** `sudo ss -ltnp | grep -E ':8081|:8082|:8083'`
- **Nginx syntax:** `sudo nginx -t`
- **Nagios syntax:** `sudo nagios3 -v /etc/nagios3/nagios.cfg`
- **Ansible package failure:** rerun `sudo apt update`; verify sudo access.
- **WSL systemctl unavailable:** enable systemd and restart WSL.
- **Terraform permission failure:** keep `/var/www` resources under Ansible; do not
  run Terraform with untrusted sudo or cloud credentials.
- **Nagios UI package is unavailable:** verify logs and package installation. The
  terminal-first status and plugin commands remain valid.

## Single-host limitations

This project cannot demonstrate network segmentation or real host-failure isolation.
The three applications are three server blocks on localhost. Nagios local plugins
execute as local processes, and stopping Nginx or SSH has the intended local effect.
Nagios notification delivery is terminal/package-default and is not a paid alerting
integration.

## Destruction

```bash
./scripts/destroy.sh development
```

Destruction removes only Terraform-managed local files/directories. It does not
uninstall Nginx, SSH, Nagios, or plugins and does not remove `/var/www` directories
unrelated to Terraform resources.
