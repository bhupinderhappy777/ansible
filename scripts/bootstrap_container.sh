#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Detect OS and Install Prerequisites
# Use sudo if not root
SUDO=""
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
fi

if [ -f /etc/redhat-release ]; then
    echo "Detected RedHat-based system"
    $SUDO dnf install -y git python3 ansible-core curl || $SUDO dnf install -y git python3 ansible curl
elif [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system"
    $SUDO apt-get update -y || echo "Warning: apt update errors, proceeding..."
    $SUDO apt-get install -y git python3 ansible curl
else
    echo "Unsupported OS. Manual intervention required."
    exit 1
fi

# 2. Setup secure workspace in user's home (avoids /tmp world-writable issues)
WORKSPACE="${HOME}/.ansible/bootstrap"
mkdir -p "$WORKSPACE"
chmod 700 "$WORKSPACE"

# 3. Handle Ansible Vault Password
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "WARNING: ANSIBLE_VAULT_PASSWORD not set. Vault-encrypted tasks will fail."
    VAULT_ARG=""
else
    echo '#!/bin/bash' > "$WORKSPACE/.vault_pass.sh"
    echo "echo $ANSIBLE_VAULT_PASSWORD" >> "$WORKSPACE/.vault_pass.sh"
    chmod +x "$WORKSPACE/.vault_pass.sh"
    VAULT_ARG="--vault-password-file $WORKSPACE/.vault_pass.sh"
fi

# 4. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL into $WORKSPACE..."

# Setting ANSIBLE_ROLES_PATH is key because the playbook is in a subfolder
# We point it to the 'roles' folder in the root of the cloned repo
export ANSIBLE_ROLES_PATH="$WORKSPACE/roles"
# Also tell ansible to use the cfg from the repo
export ANSIBLE_CONFIG="$WORKSPACE/ansible.cfg"

# Run ansible-pull
ansible-pull -U "$REPO_URL" \
    -d "$WORKSPACE" \
    -i localhost, \
    $VAULT_ARG \
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
rm -f "$WORKSPACE/.vault_pass.sh"
echo "--- Bootstrap Complete ---"
