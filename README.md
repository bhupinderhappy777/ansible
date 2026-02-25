# Ansible GitOps Bootstrap - Complete System Setup

## 🎯 **Overview**

This repository provides **fully automated GitOps provisioning** for new servers using `ansible-pull`. One command bootstraps SSH access, Tailscale VPN, and cron-based continuous sync.

**Your structure is production-grade** — follows Ansible best practices with roles, inventories, and vault encryption.

```
📁 bhupinderhappy777/ansible
├── site.yml                 # Master playbook (all-in-one)
├── ansible.cfg             # Config
├── requirements.yml        # Galaxy dependencies  
├── inventory/hosts.ini
├── group_vars/all/vault.yml # Encrypted secrets
├── playbooks/*.yml         # Individual playbooks
└── roles/tailscale/        # Custom roles
```

## 🚀 **Quick Start (Fresh System)**

### **Step 1: Install Prerequisites**
```bash
# RHEL/Fedora/CentOS/Rocky
sudo dnf install -y epel-release ansible git

# Ubuntu/Debian  
sudo apt update && sudo apt install -y ansible git
```

### **Step 2: Bootstrap Ansible User + SSH + Cron**
```bash
sudo ansible-pull -U https://github.com/bhupinderhappy777/ansible \
  -i "localhost-live,localhost," \
  playbooks/create_ansible_user.yml
```

**✅ Done**: `ansible` user created, SSH key added, sudo NOPASSWD, SSHD/firewalld configured, cron job active.

**Test**:
```bash
ssh ansible@$(hostname -I | awk '{print $1}')  # Local IP
sudo whoami  # root
```

### **Step 3: Setup Vault Password**
```bash
# As root on each node
echo "your-32-char-vault-password-here" > /root/vault_pass.txt
chmod 600 /root/vault_pass.txt
```

### **Step 4: Join Tailscale Network**
```bash
sudo ansible-pull -U https://github.com/bhupinderhappy777/ansible \
  -i "localhost-live,localhost," \
  playbooks/install-tailscale.yml \
  --vault-password-file /root/vault_pass.txt
```

**✅ Done**: Tailscale joined, SSH accessible via `100.x.x.x` Tailscale IPs.

**Test**:
```bash
tailscale status  # Logged in
ssh ansible@100.125.123.68  # Tailscale IP
```

### **Step 5: Full System Setup** (One Command)
```bash
sudo ansible-pull -U https://github.com/bhupinderhappy777/ansible \
  -i "localhost-live,localhost," \
  site.yml \
  --vault-password-file /root/vault_pass.txt
```

Runs: user → security → tailscale → packages → workstation setup.

## 🔐 **Secrets Management**

### **Add Tailscale Auth Key**
1. Generate: https://login.tailscale.com/admin/authkeys → **Reusable + Pre-approved**
2. On laptop:
```bash
# Move vars/example.yml → group_vars/all/vault.yml
cat > group_vars/all/vault.yml << 'EOF'
tailscale_auth_key: "tskey-your-key-here"
EOF

ansible-vault encrypt group_vars/all/vault.yml
git add group_vars/all/vault.yml && git commit -m "Add Tailscale vault" && git push
```

**Auto-loaded** by Ansible — no `vars_files:` needed anywhere!

## 🕐 **Cron Automation** (Auto-setup by `create_ansible_user.yml`)

```bash
# Runs every 20min, syncs all playbooks
*/20 * * * * root ansible-pull -U https://github.com/bhupinderhappy777/ansible \
  -i "localhost-live,localhost," \
  site.yml \
  --vault-password-file /root/vault_pass.txt >> /var/log/ansible-pull.log 2>&1
```

**Monitor**: `tail -f /var/log/ansible-pull.log`

## 📁 **Available Playbooks**

| Playbook | Purpose |
|---|---|
| `create_ansible_user.yml` | SSH user + sudo + cron bootstrap |
| `install-tailscale.yml` | Join Tailscale VPN |
| `security-hardening.yml` | Fail2ban + SSH hardening |
| `system-info.yml` | Gather facts |
| `update-packages.yml` | Full system upgrade |
| `ping.yml` | Connectivity test |
| `install-packages.yml` | Packages installation |

## 🛠 **Development Workflow**

```bash
# Test playbook locally
ansible-playbook -i "localhost," playbooks/install-tailscale.yml \
  --vault-password-file /root/vault_pass.txt -vvv

# Install Galaxy dependencies
ansible-galaxy install -r requirements.yml

# Lint check
ansible-lint playbooks/*.yml
```

## 🔄 **Rotate Secrets**

```bash
# New Tailscale key → re-encrypt vault
ansible-vault edit group_vars/all/vault.yml
git commit && git push  # Cron auto-deploys

# Rotate vault password  
ansible-vault rekey group_vars/all/vault.yml
# Update /root/vault_pass.txt on nodes
```

## 🧪 **Troubleshooting**

| Issue | Check |
|---|---|
| `Could not match host pattern` | Use `-i "localhost-live,localhost,"` |
| Vault empty | `ansible-vault view group_vars/all/vault.yml` |
| Cron not running | `sudo crontab -l \| grep ansible` |
| SSH Tailscale fails | `ss -tlnp \| grep 22` + `firewall-cmd --list-all` |
| Ansible-pull fails | `tail -f /var/log/ansible-pull.log` |

## 🎨 **Your Structure = Production Grade ✅**

```
✅ Playbooks organized
✅ Roles structure  
✅ Inventory setup
✅ Vault encryption
✅ GitOps cron
✅ Auto inventory fix
✅ Tailscale integration
```

**Perfect for homelab → scales to production.** Add `site.yml` + `requirements.yml` for 100% compliance. [docs.ansible](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html)

***

*Built by Bhupinder Singh Gill — Life-long learner automating the world one playbook at a time.*
