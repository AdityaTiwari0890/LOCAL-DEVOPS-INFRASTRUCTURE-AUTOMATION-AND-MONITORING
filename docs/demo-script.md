# Demo Script

## 1. Prepare

```bash
cd /path/to/terraform-ansible-static
./scripts/setup.sh
./scripts/deploy.sh development
```

## 2. Show environments

```bash
curl -I http://127.0.0.1:8081/
curl -I http://127.0.0.1:8082/
curl -I http://127.0.0.1:8083/
./scripts/status.sh
```

## 3. Demonstrate Nginx failure

```bash
sudo systemctl stop nginx
./scripts/health_check.sh
/usr/lib/nagios/plugins/check_http -p 8081 -H 127.0.0.1
sudo systemctl start nginx
./scripts/health_check.sh
```

## 4. Demonstrate SSH failure

```bash
sudo systemctl stop ssh
/usr/lib/nagios/plugins/check_ssh -p 22 127.0.0.1
sudo systemctl start ssh
/usr/lib/nagios/plugins/check_ssh -p 22 127.0.0.1
```

## 5. Close

```bash
sudo nagios3 -v /etc/nagios3/nagios.cfg
sudo systemctl status nagios3 --no-pager
./scripts/destroy.sh development
```
