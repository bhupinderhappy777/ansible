#!/bin/bash
# User-only bootstrap for Ansible Dev Env
set -euo pipefail

echo "--- Starting Container Bootstrap ---"

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: This bootstrap is user-only and must not run as root."
    exit 1
fi

# 1. Environment Variable Check (Handle sudo stripping)
if [ -z "$ANSIBLE_VAULT_PASSWORD" ]; then
    echo "ERROR: ANSIBLE_VAULT_PASSWORD is not set."
    echo "Please provide it now (input will be hidden):"
    read -rs ANSIBLE_VAULT_PASSWORD
    export ANSIBLE_VAULT_PASSWORD
fi

# 2. User-level prerequisite checks only (no sudo, no package installation)
missing_cmds=()
for cmd in git python3 curl ansible-pull ansible-galaxy; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing_cmds+=("$cmd")
    fi
done

if [ "${#missing_cmds[@]}" -gt 0 ]; then
    echo "WARNING: Missing required commands: ${missing_cmds[*]}"
    echo "WARNING: This script does not use sudo. Install prerequisites manually, then rerun."
    if [ -f /etc/debian_version ]; then
        echo "Hint: sudo apt-get update && sudo apt-get install -y git python3 ansible curl"
    elif [ -f /etc/redhat-release ]; then
        echo "Hint: sudo dnf install -y git python3 ansible-core curl"
    fi
    exit 1
fi

echo "Installing Ansible community.general collection..."
ansible-galaxy collection install community.general

# 3. Setup workspace paths
# BASE_DIR stores the password script, WORKSPACE is for the git clone
BASE_DIR="${HOME}/.ansible"
WORKSPACE="${BASE_DIR}/bootstrap"
PASS_SCRIPT="${BASE_DIR}/.vault_pass.sh"

mkdir -p "$BASE_DIR"
echo "Cleaning workspace: $WORKSPACE"
rm -rf "$WORKSPACE"

cleanup() {
    [ -f "$PASS_SCRIPT" ] && rm -f "$PASS_SCRIPT"
}
trap cleanup EXIT

# 4. Handle Ansible Vault Password (Store OUTSIDE the workspace)
echo '#!/bin/bash' > "$PASS_SCRIPT"
echo "echo '$ANSIBLE_VAULT_PASSWORD'" >> "$PASS_SCRIPT"
chmod 0700 "$PASS_SCRIPT"

# Force environment variables for the sub-process
export ANSIBLE_VAULT_PASSWORD_FILE="$PASS_SCRIPT"

# 5. Execute Ansible Pull
REPO_URL="${ANSIBLE_REPO_URL:-https://github.com/bhupinderhappy777/ansible.git}"

echo "Running ansible-pull from $REPO_URL into $WORKSPACE..."

# Path and Config Overrides
# Note: These will only be valid AFTER the clone happens
export ANSIBLE_ROLES_PATH="$WORKSPACE/roles"
export ANSIBLE_CONFIG="$WORKSPACE/ansible.cfg"

# Run ansible-pull
ansible-pull -U "$REPO_URL" \
    -d "$WORKSPACE" \
    -i localhost, \
    --vault-password-file "$PASS_SCRIPT" \
    -e bootstrap_user_only=true \
    playbooks/dev_env_setup.yml \
    --tags cli
echo "--- Bootstrap Complete ---"
