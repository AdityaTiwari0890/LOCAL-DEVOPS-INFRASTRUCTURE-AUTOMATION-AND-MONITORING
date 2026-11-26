# Architecture

The system has one Ubuntu 22.04 WSL host and three Nginx server blocks:

- Development: port 8081
- Testing: port 8082
- Production: port 8083

Terraform uses the `hashicorp/local` provider to maintain state and generate
directories, environment metadata, and the Ansible inventory. Terraform does not
model virtual machines or cloud networks.

Ansible runs through a localhost inventory. Its `users`, `nginx`, and `monitoring`
roles install/configure services and deploy templates. Handlers validate and reload
or restart changed services.

Nagios reads the standard `/etc/nagios3/nagios.cfg` and custom files under
`/etc/nagios3/conf.d`. It executes plugins for HTTP, SSH, ping, load, disk, and
process checks. This is a local-only monitoring topology.
