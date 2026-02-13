# Tailscale Role

This Ansible role installs and configures Tailscale VPN on Linux systems.

## Requirements

- Ansible 2.9 or higher
- Target systems running Ubuntu, Debian, RHEL, or CentOS

## Role Variables

Available variables with their default values (see `defaults/main.yml`):

```yaml
# Tailscale authentication key (required for automatic connection)
tailscale_auth_key: ""

# Additional arguments to pass to 'tailscale up' command
tailscale_args: ""

# Whether to automatically connect to Tailscale network
tailscale_up: true
```

## Dependencies

None.

## Example Playbook

```yaml
---
- hosts: servers
  become: yes
  roles:
    - role: tailscale
      vars:
        tailscale_auth_key: "tskey-auth-xxxxx"
        tailscale_args: "--accept-routes"
```

## Usage Examples

### Basic Installation

```yaml
- hosts: all
  roles:
    - tailscale
```

### With Authentication Key

```yaml
- hosts: all
  roles:
    - role: tailscale
      vars:
        tailscale_auth_key: "{{ vault_tailscale_auth_key }}"
```

### As an Exit Node

```yaml
- hosts: exit_node
  roles:
    - role: tailscale
      vars:
        tailscale_auth_key: "tskey-auth-xxxxx"
        tailscale_args: "--advertise-exit-node"
```

### With Subnet Routes

```yaml
- hosts: routers
  roles:
    - role: tailscale
      vars:
        tailscale_auth_key: "tskey-auth-xxxxx"
        tailscale_args: "--advertise-routes=10.0.0.0/24,192.168.1.0/24"
```

## License

MIT

## Author Information

Infrastructure Team
