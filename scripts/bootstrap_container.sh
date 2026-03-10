#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Detect OS and Install Prerequisites
SUDO=""
[ "$EUID" -ne 0 ] && SUDO="sudo"

if [ -f /etc/redhat-release ]; then
    echo "Detected RedHat-based system"
    $SUDO dnf install -y git python3 ansible-core curl || $SUDO dnf install -y git python3 ansible curl
elif [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system"
    $SUDO apt-get update -y || echo "Warning: apt update errors, proceeding..."
    $SUDO apt-get install -y git python3 ansible curl
fi

# 2. Setup secure workspace (Use current user's home to avoid root/user path confusion)
WORKSPACE="${HOME}/.ansible/bootstrap"
mkdir -p "$WORKSPACE"
chmod 700 "$WORKSPACE"

# 3. Handle Ansible Vault Password
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "WARNING: ANSIBLE_VAULT_PASSWORD not set. Vault-encrypted tasks will fail."
else
    # Create the temporary password script
    PASS_SCRIPT="$WORKSPACE/.vault_pass.sh"
    echo '#!/bin/bash' > "$PASS_SCRIPT"
    echo "echo '$ANSIBLE_VAULT_PASSWORD'" >> "$PASS_SCRIPT"
    chmod +x "$PASS_SCRIPT"
    
    # FORCE OVERRIDE: Set environment variable to override ansible.cfg
    export ANSIBLE_VAULT_PASSWORD_FILE="$PASS_SCRIPT"
    echo "Vault password override configured."
fi

# 4. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL into $WORKSPACE..."

# Ensure we point to the roles and config in the cloned repo
export ANSIBLE_ROLES_PATH="$WORKSPACE/roles"
export ANSIBLE_CONFIG="$WORKSPACE/ansible.cfg"

# Run ansible-pull
ansible-pull -U "$REPO_URL" \
    -d "$WORKSPACE" \
    -i localhost, \
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
[ -f "$PASS_SCRIPT" ] && rm -f "$PASS_SCRIPT"
echo "--- Bootstrap Complete ---"
