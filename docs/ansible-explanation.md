# Ansible

Run the playbook with the localhost inventory:

```bash
cd ansible
ansible-playbook --syntax-check -i inventory/hosts.ini site.yml
ansible-playbook -i inventory/hosts.ini site.yml
```

The `users` role creates the `devops` account and project directories. The `nginx`
role installs Nginx and SSH, creates the application directories, deploys HTML
templates and server blocks, and starts services.

The `monitoring` role installs Nagios and plugins and installs a custom configuration
under `/etc/nagios3/conf.d`. The handlers execute `nginx -t` or
`nagios3 -v /etc/nagios3/nagios.cfg` before reload/restart.
