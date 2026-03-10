#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Environment Variable Check (Handle sudo stripping)
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "ERROR: ANSIBLE_VAULT_PASSWORD is not set."
    echo "Please provide it now (input will be hidden):"
    read -rs ANSIBLE_VAULT_PASSWORD
    export ANSIBLE_VAULT_PASSWORD
fi

# 2. Detect OS and Install Prerequisites
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

# 3. Setup secure workspace (Self-cleaning to avoid "directory already exists" errors)
WORKSPACE="${HOME}/.ansible/bootstrap"
echo "Cleaning workspace: $WORKSPACE"
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"
chmod 700 "$WORKSPACE"

# 4. Handle Ansible Vault Password
PASS_SCRIPT="$WORKSPACE/.vault_pass.sh"
echo '#!/bin/bash' > "$PASS_SCRIPT"
echo "echo '$ANSIBLE_VAULT_PASSWORD'" >> "$PASS_SCRIPT"
chmod +x "$PASS_SCRIPT"

# Force environment variables for the sub-process
export ANSIBLE_VAULT_PASSWORD_FILE="$PASS_SCRIPT"

# 5. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL into $WORKSPACE..."

# Path and Config Overrides
export ANSIBLE_ROLES_PATH="$WORKSPACE/roles"
export ANSIBLE_CONFIG="$WORKSPACE/ansible.cfg"

# Run ansible-pull
ansible-pull -U "$REPO_URL" \
    -d "$WORKSPACE" \
    -i localhost, \
    --vault-password-file "$PASS_SCRIPT" \
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
[ -f "$PASS_SCRIPT" ] && rm -f "$PASS_SCRIPT"
echo "--- Bootstrap Complete ---"
