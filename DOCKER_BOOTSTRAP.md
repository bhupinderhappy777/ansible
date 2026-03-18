# Docker & Container Bootstrap Guide

This guide describes how to automate the setup of your development environment in a brand-new container using `ansible-pull` in strict user-only mode.

## Overview

The setup process is split into two phases:
1.  **Bootstrap Phase:** A shell script validates minimal dependencies (Git, Python, Ansible).
2.  **Automation Phase:** `ansible-pull` clones this repository and executes `playbooks/dev_env_setup.yml` with the `cli` tag.

## Prerequisites

1.  **Internet Access:** To clone the repository and download user-space tooling.
2.  **Ansible Vault Password:** Required for decrypting secrets (SSH keys, etc.).
3.  **Preinstalled Prerequisites:** `git`, `python3`, `curl`, `ansible-pull`, and `ansible-galaxy` must already be installed by the image or host provisioning process.
3.  **SSH Keys (Optional):** If your repository or OCI configuration requires specific SSH keys before Ansible can run, these must be mounted or injected.

## 1. Automation Workflow

### Handling the Vault Password
Since `ansible-pull` is non-interactive, you must provide the vault password via an environment variable. The bootstrap script will automatically create a temporary password provider for Ansible.

**Method: Environment Variable (Recommended)**
```bash
export ANSIBLE_VAULT_PASSWORD="your_vault_password"
```

## 2. Execution Commands

### One-Liner (Remote Execution)
If you have hosted the `scripts/bootstrap_container.sh` file on a public URL (e.g., GitHub Raw):

```bash
curl -sSL raw.githubusercontent.com/bhupinderhappy777/ansible/refs/heads/main/scripts/bootstrap_container.sh | bash
```

### Docker Run Example
To start a fresh container and immediately set up the environment:

```bash
docker run -it \
  -e ANSIBLE_VAULT_PASSWORD="your_vault_password" \
  fedora:40 /bin/bash -c "curl -sSL <URL_TO_SCRIPT> | bash"
```

## 3. What is Handled?

| Task | Handled By |
| :--- | :--- |
| **Prerequisites** (checks only) | `scripts/bootstrap_container.sh` |
| **Dotfiles** | `roles/chezmoi` (CLI tasks) |
| **SSH Keys** | `roles/clone_dotfiles` (Decrypted from Vault) |
| **Shell** (ZSH, Plugins) | `roles/zsh` |
| **Cloud Config** (OCI SDK) | `roles/management` |

## 4. Troubleshooting

- **Vault Failures:** Ensure `ANSIBLE_VAULT_PASSWORD` is exported correctly. Without it, tasks involving encrypted files (like SSH keys) will fail.
- **Permission Denied:** This script is user-only. Do not run it as `root`, and do not expect it to invoke `sudo`.
- **Missing Prerequisites:** Install required tools at image build time or with a separate privileged provisioning step.
- **GUI Tasks:** By default, the `cli` tag is used to avoid errors in headless containers. If you are in a GUI-capable container, you can remove the `--tags cli` from the bootstrap script or manually run `ansible-playbook playbooks/dev_env_setup.yml --tags gui`.
