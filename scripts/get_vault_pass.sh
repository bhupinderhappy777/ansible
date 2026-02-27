#!/bin/bash
OCI_BIN="/home/bhupi/bin/oci"
OCID=$(grep "ansible_vault_secret_ocid" ~/.oci/config | cut -d'=' -f2 | xargs)

if [ -z "$OCID" ]; then
    echo "Error: OCID not found in ~/.oci/config" >&2
    exit 1
fi

$OCI_BIN secrets secret-bundle get --secret-id "$OCID" \
  --query "data.\"secret-bundle-content\".content" --raw-output | base64 --decode
