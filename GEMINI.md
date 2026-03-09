# GEMINI.md - 2026 Hybrid-Cloud Automation Project

## Project Overview
This repository manages a distributed hybrid-cloud infrastructure across **Oracle Cloud Infrastructure (OCI)** ARM instances and a **Local Home-Lab** environment. It uses **Ansible** for configuration management, **Tailscale** for secure mesh networking, and **OCI Vault** for dynamic secret retrieval.

- **Main Technologies:** Ansible, OCI (ARM-based), Tailscale, Ed25519 SSH, Python.
- **Architecture:** Hybrid-cloud (OCI + Home-Lab) connected via Tailscale. The `ociubuntu` node acts as a decentralized controller.
- **Primary Goal:** Automate the provisioning, security hardening, and maintenance of a multi-cloud server fleet.

## Recent Project Overhaul
The project has undergone a significant architectural and structural streamlining:
- **Directory Consolidation:** All root-level playbooks were moved to `playbooks/` and scripts to `scripts/` to maintain a clean root directory.
- **Robustness Improvements:**
  - **Tailscale:** Transitioned from `curl | sh` to native package repository management for Debian/RedHat. Added JSON-based status parsing for more reliable authentication.
  - **SSH/Security:** Standardized on unified handler names (`Restart SSH`, `Reload firewalld`, `Reload ufw`) across all roles and playbooks.
  - **Standardization:** Updated tasks to use Fully Qualified Collection Names (FQCN) and added validation steps for critical configuration changes (e.g., `sshd -t`).
  - **Role Optimization:** Refactored `bootstrap` and `zsh` roles to eliminate redundancies and improve cross-platform compatibility.

## Project Structure
...
- `playbooks/site.yml`: The master playbook for full infrastructure state application.
- `ansible.cfg`: Configured for SSH pipelining, automatic vault password retrieval, and strict host key checking.
- `inventory/hosts.ini`: Defines host groups (`oci_nodes`, `home_lab`, `cloud`, `production`) using Tailscale IPs.
- `roles/`: Modular components (bootstrap, common, tailscale, security_hardening, stow, zsh, etc.).
- `playbooks/`: Specific task-oriented playbooks (ping, security-hardening, install-packages, core_setup, dev_env_setup, etc.).
- `scripts/get_vault_pass.sh`: A critical utility that uses OCI CLI to fetch Ansible Vault passwords from OCI Secrets.
- `Makefile`: Provides a simplified CLI interface for common management tasks.

## Building and Running
The project uses a `Makefile` to streamline operations.

| Command | Action |
| :--- | :--- |
| `make all` | Run the full deployment (`playbooks/site.yml`). |
| `make bootstrap` | Execute the bootstrap role for initial node setup. |
| `make security` | Run security hardening tasks. |
| `make lint` | Perform `ansible-lint` and log results to `logs/`. |
| `ansible-playbook playbooks/ping.yml` | Verify connectivity to all nodes. |

### Prerequisites
- **Ansible:** Installed on the management node.
- **OCI CLI:** Configured with appropriate IAM permissions to fetch secrets.
- **Environment Variable:** `ANSIBLE_SECRET_OCID` must be set for vault access.
- **SSH Keys:** Ed25519 keys must be present at `~/.ssh/id_ed25519`.

## Development Conventions
- **Connectivity:** All hosts must be accessed via their **Tailscale IPs** (100.x.x.x range) to ensure encrypted transit.
- **Privilege Escalation:** Use `become: true` for system-level tasks. Many roles default to this.
- **Secret Management:** Never store plain-text passwords. Use `ansible-vault` and the OCI retrieval script.
- **Modularity:** New functionality should be implemented as **Roles** in the `roles/` directory.
- **Testing:** Use `molecule` for role testing. The project includes a basic Molecule configuration in `molecule/default/`.
- **Environment Setup:** 
  - `playbooks/dev_env_setup.yml`: Sets up the local development environment (dotfiles, zsh, etc.).
  - `playbooks/core_setup.yml`: A comprehensive workstation personalization playbook.

## Key Files for Reference
- `ansible.cfg`: Global Ansible settings.
- `inventory/hosts.ini`: Current infrastructure map.
- `playbooks/site.yml`: High-level role orchestration.
- `scripts/get_vault_pass.sh`: Entry point for secret management.
- `QUICK_START.md`: Detailed onboarding guide.
