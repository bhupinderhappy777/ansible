#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

echo "--- Starting Container Bootstrap ---"

# 1. Environment Variable Check
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "ERROR: ANSIBLE_VAULT_PASSWORD is not set."
    echo "If you are using sudo, run: sudo -E bash $0"
    echo "Or provide it now (input will be hidden):"
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

# 3. Setup secure workspace
# We use /tmp but with secure permissions to avoid world-writable issues
WORKSPACE="/tmp/ansible_bootstrap_$(date +%s)"
mkdir -p "$WORKSPACE"
chmod 700 "$WORKSPACE"

# 4. Handle Ansible Vault Password
# Create the temporary password script
PASS_SCRIPT="$WORKSPACE/.vault_pass.sh"
echo '#!/bin/bash' > "$PASS_SCRIPT"
echo "echo '$ANSIBLE_VAULT_PASSWORD'" >> "$PASS_SCRIPT"
chmod +x "$PASS_SCRIPT"

# Force environment variables for the ansible-pull sub-process
export ANSIBLE_VAULT_PASSWORD_FILE="$PASS_SCRIPT"

# 5. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL into $WORKSPACE..."

# Ensure we point to the roles and config in the cloned repo
export ANSIBLE_ROLES_PATH="$WORKSPACE/roles"
export ANSIBLE_CONFIG="$WORKSPACE/ansible.cfg"

# Run ansible-pull with explicit vault argument to be certain
ansible-pull -U "$REPO_URL" \
    -d "$WORKSPACE" \
    -i localhost, \
    --vault-password-file "$PASS_SCRIPT" \
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
[ -f "$PASS_SCRIPT" ] && rm -f "$PASS_SCRIPT"
echo "--- Bootstrap Complete ---"
