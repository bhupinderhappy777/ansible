#!/bin/bash
# Universal Bootstrap for Ansible Dev Env
set -e

repair_yarn_apt_repo() {
    local SUDO_CMD="$1"
    local keyring_dir="/etc/apt/keyrings"
    local keyring_file="${keyring_dir}/yarn-archive-keyring.gpg"
    local key_url="https://dl.yarnpkg.com/debian/pubkey.gpg"

    if [ ! -f /etc/debian_version ]; then
        return 0
    fi

    if ! grep -Rqs "dl.yarnpkg.com/debian" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
        return 0
    fi

    echo "Detected Yarn APT repository; ensuring keyring and signed-by are configured..."
    $SUDO_CMD mkdir -p "$keyring_dir"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$key_url" | $SUDO_CMD gpg --dearmor -o "$keyring_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$key_url" | $SUDO_CMD gpg --dearmor -o "$keyring_file"
    else
        echo "WARNING: curl/wget not found; cannot refresh Yarn key automatically."
        return 0
    fi

    $SUDO_CMD chmod 0644 "$keyring_file"

    $SUDO_CMD sh -c "printf '%s\n' 'deb [signed-by=$keyring_file] https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list"
}

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
    $SUDO ansible-galaxy collection install community.general
elif [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system"
    $SUDO apt-get install -y ca-certificates gnupg >/dev/null 2>&1 || true
    repair_yarn_apt_repo "$SUDO"
    $SUDO apt-get update -y || echo "Warning: apt update errors, proceeding..."
    $SUDO apt-get install -y git python3 ansible curl
    $SUDO ansible-galaxy collection install community.general
fi

# 3. Setup workspace paths
# BASE_DIR stores the password script, WORKSPACE is for the git clone
BASE_DIR="${HOME}/.ansible"
WORKSPACE="${BASE_DIR}/bootstrap"
PASS_SCRIPT="${BASE_DIR}/.vault_pass.sh"

mkdir -p "$BASE_DIR"
echo "Cleaning workspace: $WORKSPACE"
rm -rf "$WORKSPACE"

# 4. Handle Ansible Vault Password (Store OUTSIDE the workspace)
echo '#!/bin/bash' > "$PASS_SCRIPT"
echo "echo '$ANSIBLE_VAULT_PASSWORD'" >> "$PASS_SCRIPT"
chmod +x "$PASS_SCRIPT"

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
    playbooks/dev_env_setup.yml \
    --tags cli

# Cleanup
[ -f "$PASS_SCRIPT" ] && rm -f "$PASS_SCRIPT"
echo "--- Bootstrap Complete ---"
