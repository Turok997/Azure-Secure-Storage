#!/bin/bash
# Technical validation of the Secure Enclave

STORAGE_NAME="stsecureXXXX" # Replace with actual name

echo "1. Testing Public Access (Expected: 403 Forbidden)..."
curl -I https://$STORAGE_NAME.blob.core.windows.net/internal-data
# This should fail from your local machine, proving network isolation.

echo "2. Testing DNS Resolution..."
nslookup $STORAGE_NAME.blob.core.windows.net
# From within the VNet, this must return a 10.1.1.x address.