#!/bin/bash
# Quick start script to validate Ansible setup

set -e

echo "=== Ansible IaaC Setup Validation ==="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed"
    echo "   Install with: sudo apt install ansible  (Ubuntu/Debian)"
    echo "   Or: brew install ansible  (macOS)"
    echo "   Or: pip install ansible"
    exit 1
fi

echo "✓ Ansible is installed"
ansible --version | head -n 1

# Check ansible.cfg
if [ -f "ansible.cfg" ]; then
    echo "✓ ansible.cfg found"
else
    echo "❌ ansible.cfg not found"
    exit 1
fi

# Check inventory
if [ -f "inventory/hosts.ini" ]; then
    echo "✓ Inventory file found"
else
    echo "❌ Inventory file not found"
    exit 1
fi

# Check roles
if [ -d "roles/tailscale" ]; then
    echo "✓ Tailscale role found"
else
    echo "❌ Tailscale role not found"
    exit 1
fi

# List inventory
echo ""
echo "=== Inventory Summary ==="
ansible-inventory --list -i inventory/hosts.ini | grep -E '"_(meta|children|hosts)"' | head -n 20 || true

echo ""
echo "=== Next Steps ==="
echo "1. Edit inventory/hosts.ini and add your VM IP addresses"
echo "2. Test connectivity: ansible-playbook playbooks/ping.yml"
echo "3. Install Tailscale: ansible-playbook playbooks/install-tailscale.yml -e 'tailscale_auth_key=tskey-xxx'"
echo ""
echo "For more information, see README.md"
