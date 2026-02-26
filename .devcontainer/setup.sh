#!/bin/bash
set -e
pip install --user ansible
eval $(ssh-agent -s)
echo "$ANSIBLE_SSH_KEY" | tr -d '\r' | ssh-add -
echo "Ansible + SSH setup complete!"
