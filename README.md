# Multi-Cloud Infrastructure as Code with Ansible

This repository provides a ready-to-use Infrastructure as Code (IaaC) setup using Ansible to manage VMs across multiple cloud providers (AWS, Azure, GCP, DigitalOcean, etc.) and configure them with essential tools like Tailscale.

## 📁 Repository Structure

```
.
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.ini           # Inventory file with cloud VMs
├── group_vars/             # Group-specific variables
│   ├── aws.yml
│   ├── azure.yml
│   ├── gcp.yml
│   └── digitalocean.yml
├── host_vars/              # Host-specific variables
├── roles/
│   └── tailscale/          # Tailscale installation role
│       ├── tasks/
│       ├── defaults/
│       ├── handlers/
│       ├── templates/
│       └── meta/
└── playbooks/              # Ansible playbooks
    ├── install-tailscale.yml
    ├── ping.yml
    └── system-info.yml
```

## 🚀 Quick Start

### Prerequisites

1. **Install Ansible**:
   ```bash
   # On Ubuntu/Debian
   sudo apt update
   sudo apt install ansible
   
   # On macOS
   brew install ansible
   
   # Using pip
   pip install ansible
   ```

2. **SSH Access**: Ensure you have SSH access to your VMs with key-based authentication.

### Setup

1. **Clone this repository**:
   ```bash
   git clone <your-repo-url>
   cd ansible
   ```

2. **Configure your inventory**:
   Edit `inventory/hosts.ini` and add your VM IP addresses:
   ```ini
   [aws]
   aws-vm-1 ansible_host=3.xxx.xxx.xxx
   
   [azure]
   azure-vm-1 ansible_host=20.xxx.xxx.xxx
   
   [gcp]
   gcp-vm-1 ansible_host=35.xxx.xxx.xxx
   ```

3. **Test connectivity**:
   ```bash
   ansible-playbook playbooks/ping.yml
   ```

## 📖 Usage

### Install Tailscale on All Cloud VMs

To install Tailscale on all your cloud VMs:

```bash
ansible-playbook playbooks/install-tailscale.yml
```

**With Tailscale auth key** (recommended):
```bash
ansible-playbook playbooks/install-tailscale.yml -e "tailscale_auth_key=tskey-auth-xxxxx"
```

**With additional Tailscale arguments**:
```bash
ansible-playbook playbooks/install-tailscale.yml \
  -e "tailscale_auth_key=tskey-auth-xxxxx" \
  -e "tailscale_args='--advertise-routes=10.0.0.0/8'"
```

### Target Specific Cloud Provider

```bash
# Only AWS VMs
ansible-playbook playbooks/install-tailscale.yml --limit aws

# Only Azure VMs
ansible-playbook playbooks/install-tailscale.yml --limit azure

# Specific host
ansible-playbook playbooks/install-tailscale.yml --limit aws-vm-1
```

### Gather System Information

```bash
ansible-playbook playbooks/system-info.yml
```

### Run Ad-Hoc Commands

```bash
# Check uptime on all hosts
ansible all -a "uptime"

# Update packages on Ubuntu/Debian hosts
ansible cloud -m apt -a "update_cache=yes upgrade=dist" --become

# Restart a service
ansible cloud -m systemd -a "name=tailscaled state=restarted" --become
```

## 🔧 Configuration

### Tailscale Role Variables

Configure these in `group_vars/`, `host_vars/`, or pass via command line:

| Variable | Default | Description |
|----------|---------|-------------|
| `tailscale_auth_key` | `""` | Tailscale authentication key |
| `tailscale_args` | `""` | Additional arguments for `tailscale up` |
| `tailscale_up` | `true` | Whether to automatically connect to Tailscale |

### Example: Host-Specific Configuration

Create `host_vars/aws-vm-1.yml`:
```yaml
---
tailscale_auth_key: "tskey-auth-xxxxx"
tailscale_args: "--advertise-routes=10.0.1.0/24 --accept-routes"
```

## 🌐 Supported Cloud Providers

This setup works with VMs from any cloud provider. The inventory includes examples for:

- **AWS EC2**
- **Azure Virtual Machines**
- **Google Cloud Platform (GCP)**
- **DigitalOcean Droplets**
- **Any other cloud or on-premise VMs**

## 🔐 Security Best Practices

1. **SSH Keys**: Use SSH keys instead of passwords
2. **Ansible Vault**: Store sensitive data (auth keys, passwords) in Ansible Vault:
   ```bash
   ansible-vault create group_vars/all/vault.yml
   ansible-playbook playbooks/install-tailscale.yml --ask-vault-pass
   ```
3. **Limited User Access**: Use non-root users with sudo privileges
4. **Firewall Rules**: Configure appropriate firewall rules on your VMs

## 📝 Creating Additional Roles

To add more functionality, create additional roles:

```bash
# Create a new role
mkdir -p roles/my-role/{tasks,defaults,handlers,templates,meta}

# Edit the tasks
vim roles/my-role/tasks/main.yml

# Use in playbook
# roles:
#   - my-role
```

## 🤝 Contributing

Feel free to add more roles, playbooks, and configurations to extend this IaaC setup!

## 📚 Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## 📄 License

MIT License - feel free to use and modify as needed.