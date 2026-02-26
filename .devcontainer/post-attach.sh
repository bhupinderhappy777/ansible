#!/bin/bash
set -e
echo "TS_AUTHKEY length: ${#TS_AUTHKEY}, value: $TS_AUTHKEY"
curl -fsSL https://tailscale.com/install.sh | sh
sudo mkdir -p /var/lib/tailscale /var/run/tailscale
sudo pkill tailscaled || true
sudo tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
sleep 10
for i in {1..10}; do
  if tailscale status >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
sudo -E tailscale up --authkey="$TS_AUTHKEY" --accept-routes --accept-dns=false --force-reauth
tailscale status
pip install --user ansible
eval $(ssh-agent -s)
echo "$ANSIBLE_SSH_KEY" | tr -d '\r' | ssh-add -
echo 'Tailscale+Ansible ready!'