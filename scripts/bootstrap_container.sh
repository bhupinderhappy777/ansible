#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Detect OS and Install Prerequisites
if [ -f /etc/redhat-release ]; then
    echo "Detected RedHat-based system"
    dnf install -y git python3 ansible-core curl
elif [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system"
    apt-get update && apt-get install -y git python3 ansible curl
else
    echo "Unsupported OS. Manual intervention required."
    exit 1
fi

# 2. Handle Ansible Vault Password
# We create a temporary script that Ansible can call to get the password
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "WARNING: ANSIBLE_VAULT_PASSWORD not set. Vault-encrypted tasks will fail."
    VAULT_ARG=""
else
    # Create a temporary vault password script for ansible-pull
    echo '#!/bin/bash' > /tmp/.vault_pass.sh
    echo "echo $ANSIBLE_VAULT_PASSWORD" >> /tmp/.vault_pass.sh
    chmod +x /tmp/.vault_pass.sh
    VAULT_ARG="--vault-password-file /tmp/.vault_pass.sh"
fi

# 3. Execute Ansible Pull
# Uses the provided repository URL or defaults to your project
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL..."
ansible-pull -U "$REPO_URL" \
    -d /tmp/ansible_bootstrap \
    -i localhost, \
    $VAULT_ARG \
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
rm -f /tmp/.vault_pass.sh
echo "--- Bootstrap Complete ---"
