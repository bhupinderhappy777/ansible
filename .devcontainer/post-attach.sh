#!/bin/bash
set -e
curl -fsSL https://tailscale.com/install.sh | sh
export TS_AUTHKEY
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
sudo -E tailscale up --authkey="$TS_AUTHKEY" --accept-routes --accept-dns=true
tailscale status
pip install --user ansible
eval $(ssh-agent -s)
if [ -n "$ANSIBLE_SSH_KEY" ]; then
  echo "$ANSIBLE_SSH_KEY" | tr -d '\r' | ssh-add - 2>/dev/null || echo "Warning: Failed to add SSH key"
else
  echo "Warning: ANSIBLE_SSH_KEY not set"
fi
echo 'Tailscale+Ansible ready!'