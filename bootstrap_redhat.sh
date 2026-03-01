#!/bin/bash
# ==============================================================================
# Fedora Workstation Bootstrapper
# Uses ansible-pull to configure the system directly from GitHub.
# ==============================================================================
set -e

# --- Configuration ---
REPO_URL="https://github.com/bhupinderhappy777/ansible.git"
BRANCH="dotfiles"
PLAYBOOK="personalization.yml"

echo "🚀 Starting Workstation Kickstart..."
echo "📍 Source: $REPO_URL ($BRANCH)"

# 1. Update System and Install Core Requirements
echo "📦 Updating DNF and installing base dependencies..."
sudo dnf update -y
sudo dnf install -y git python3-pip pipx

# 2. Setup Ansible via pipx
# We use pipx to keep the system Python clean
export PATH="$HOME/.local/bin:$PATH"
if ! command -v ansible &> /dev/null; then
    echo "🐍 Installing Ansible Core..."
    pipx install ansible-core --force
fi

# 3. Install Required Ansible Collections
echo "🔗 Installing community.general and ansible.posix..."
ansible-galaxy collection install community.general ansible.posix

# 4. Execute ansible-pull
# -U: URL of the repository
# -C: Checkout the specific branch
# -K: Ask for become (sudo) password (needed for the first run)
# -i: Uses a local-only inventory logic
echo "🔄 Handing control to ansible-pull..."
ansible-pull -U "$REPO_URL" \
             -C "$BRANCH" \
             --ask-vault-pass \
             -K \
             "$PLAYBOOK"

echo "=================================================================="
echo "✅ Setup complete!"
echo "💡 Note: You may need to log out and back in for shell changes (Zsh)."
echo "=================================================================="
