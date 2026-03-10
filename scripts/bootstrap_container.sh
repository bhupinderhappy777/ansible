#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Detect OS and Install Prerequisites
if [ -f /etc/redhat-release ]; then
    echo "Detected RedHat-based system"
    # DNF5/DNF handles partial failures better
    dnf install -y git python3 ansible-core curl || dnf install -y git python3 ansible curl
elif [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system"
    # Allow update to fail (common in Codespaces/dirty images) but still try to install
    apt-get update -y || echo "Warning: apt-get update encountered errors, attempting install anyway..."
    apt-get install -y git python3 ansible curl
else
    echo "Unsupported OS. Manual intervention required."
    exit 1
fi

# 2. Handle Ansible Vault Password
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "WARNING: ANSIBLE_VAULT_PASSWORD not set. Vault-encrypted tasks will fail."
    VAULT_ARG=""
else
    echo '#!/bin/bash' > /tmp/.vault_pass.sh
    echo "echo $ANSIBLE_VAULT_PASSWORD" >> /tmp/.vault_pass.sh
    chmod +x /tmp/.vault_pass.sh
    VAULT_ARG="--vault-password-file /tmp/.vault_pass.sh"
fi

# 3. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

# Ensure we use the full path to ansible-pull if needed, 
# but usually apt-get puts it in /usr/bin/ansible-pull
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
