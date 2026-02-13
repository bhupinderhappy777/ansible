# Quick Start Guide

This guide will help you get up and running with this Ansible Infrastructure as Code repository quickly.

## Step 1: Prerequisites

Install Ansible on your local machine:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible

# Using pip
pip install ansible
```

## Step 2: Add Your Hosts

Edit `inventory/hosts.ini` and add your VM IP addresses or hostnames:

```ini
[aws]
aws-vm-1 ansible_host=54.123.45.67

[azure]
azure-vm-1 ansible_host=20.123.45.67

[gcp]
gcp-vm-1 ansible_host=35.123.45.67
```

## Step 3: Test Connectivity

Verify that Ansible can connect to your hosts:

```bash
ansible-playbook playbooks/ping.yml
```

If this fails, check:
- Your SSH keys are properly set up
- You can manually SSH to the hosts: `ssh ubuntu@54.123.45.67`
- The ansible_user in inventory matches your SSH user

## Step 4: Install Tailscale

### Option A: With Auth Key (Recommended)

Get your auth key from https://login.tailscale.com/admin/settings/keys

```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key=tskey-auth-xxxxx-yyyyy"
```

### Option B: Using Variables File

1. Copy the example: `cp vars/example.yml vars/my-vars.yml`
2. Edit `vars/my-vars.yml` and uncomment/set `tailscale_auth_key`
3. Run: `ansible-playbook playbooks/install-tailscale.yml -e @vars/my-vars.yml`

### Option C: Manual Connection

Install without auto-connecting:

```bash
ansible-playbook playbooks/install-tailscale.yml -e "tailscale_up=false"
```

Then SSH to each host and run: `sudo tailscale up`

## Step 5: Verify Installation

Check system information:

```bash
ansible-playbook playbooks/system-info.yml
```

## Common Tasks

### Update All Packages

```bash
ansible-playbook playbooks/update-packages.yml
```

### Security Hardening

```bash
ansible-playbook playbooks/security-hardening.yml
```

### Target Specific Hosts

```bash
# Only AWS hosts
ansible-playbook playbooks/install-tailscale.yml --limit aws

# Single host
ansible-playbook playbooks/install-tailscale.yml --limit aws-vm-1
```

### Run Ad-Hoc Commands

```bash
# Check uptime
ansible all -a "uptime"

# Check disk space
ansible all -a "df -h"

# Restart Tailscale
ansible all -m systemd -a "name=tailscaled state=restarted" --become
```

## Advanced: Using Ansible Vault for Secrets

Store sensitive data securely:

```bash
# Create vault password file
echo "my-secret-password" > .vault_pass

# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml

# Add your secrets:
# vault_tailscale_auth_key: "tskey-auth-xxxxx"

# Reference in playbook
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key={{ vault_tailscale_auth_key }}" \
  --vault-password-file .vault_pass
```

## Troubleshooting

### Can't connect to hosts

- Verify SSH access: `ssh user@host`
- Check inventory ansible_user matches your SSH user
- Verify ansible_host IP addresses are correct

### Permission denied

- Ensure your user has sudo access: `sudo -v`
- Check ansible.cfg has `become=True`

### Tailscale not connecting

- Verify auth key is valid and not expired
- Check Tailscale logs: `sudo journalctl -u tailscaled`

## Next Steps

- Add more hosts to your inventory
- Create custom roles for your specific needs
- Explore additional playbooks in the `playbooks/` directory
- Read the full README.md for more details

## Getting Help

- [Ansible Documentation](https://docs.ansible.com/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- Check existing issues in this repository
