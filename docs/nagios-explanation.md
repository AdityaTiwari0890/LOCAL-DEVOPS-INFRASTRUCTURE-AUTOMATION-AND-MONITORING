# Nagios

Ubuntu 22.04 commonly exposes Nagios as `nagios3`, plugin binaries under
`/usr/lib/nagios/plugins`, and custom configuration in
`/etc/nagios3/conf.d`. The playbook uses these existing paths and does not replace
the main configuration.

Custom checks:

| Check | Command intent | Warning/Critical |
|---|---|---|
| Ping | `check_ping` | 100ms/20% and 200ms/40% |
| HTTP | `check_http` | connection/HTTP failure |
| SSH | `check_ssh` | connection failure |
| CPU | `check_load` | 4/3/2 and 6/5/4 |
| Disk | `check_disk` | 20% and 10% free |
| Processes | `check_procs` | 250 and 400 |

Validate before restart:

```bash
sudo nagios3 -v /etc/nagios3/nagios.cfg
sudo systemctl restart nagios3
```

Nagios service status and plugin outputs are available through systemctl and direct
plugin execution. Package availability can vary by Ubuntu repository configuration.
