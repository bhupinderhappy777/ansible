#!/bin/bash

# 1. Point to the binary inside the venv
OCI_BIN="/opt/oci/bin/oci"

# 2. Define the path to your config and vault OCID
# You can hardcode this or use your service_user variable logic
CONFIG_FILE="$HOME/.oci/config"

# 3. Extract the Secret OCID. 
# Added a check to ensure we are pulling from the right file
OCID=$(grep "ansible_vault_secret_ocid" "$CONFIG_FILE" | cut -d'=' -f2 | xargs)

if [ -z "$OCID" ]; then
    echo "Error: ansible_vault_secret_ocid not found in $CONFIG_FILE" >&2
    exit 1
fi

# 4. Execute the OCI call
# We use the full path to the binary so we don't need to 'activate' the venv
$OCI_BIN secrets secret-bundle get \
    --secret-id "$OCID" \
    --query "data.\"secret-bundle-content\".content" \
    --raw-output | base64 --decode
