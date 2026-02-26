#!/bin/bash

# Check if the OCID is set as an environment variable
if [ -z "$ANSIBLE_SECRET_OCID" ]; then
    echo "Error: ANSIBLE_SECRET_OCID is not set." >&2
    exit 1
fi

# Fetch the secret using the environment variable
oci secrets secret-bundle get --secret-id "$ANSIBLE_SECRET_OCID" \
  --query "data.\"secret-bundle-content\".content" --raw-output | base64 --decode
