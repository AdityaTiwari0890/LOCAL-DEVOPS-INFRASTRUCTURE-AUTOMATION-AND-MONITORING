#!/usr/bin/env bash
set -u

status=0
for endpoint in \
  "development|http://127.0.0.1:8081/" \
  "testing|http://127.0.0.1:8082/" \
  "production|http://127.0.0.1:8083/"
do
  IFS='|' read -r name url <<< "$endpoint"
  if curl --fail --silent --show-error --max-time 5 "$url" >/dev/null; then
    printf "%-12s OK  %s\n" "$name" "$url"
  else
    printf "%-12s CRITICAL  %s\n" "$name" "$url"
    status=1
  fi
done

if timeout 5 bash -c 'echo >/dev/tcp/127.0.0.1/22' 2>/dev/null; then
  echo "SSH          OK  127.0.0.1:22"
else
  echo "SSH          CRITICAL  127.0.0.1:22"
  status=1
fi

exit "$status"
