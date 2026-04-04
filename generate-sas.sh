#!/bin/bash
# Description: Generates a SAS token restricted to the internal VNet range
# demonstrating advanced network-level access control.

STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
CONTAINER_NAME="internal-data"
EXPIRY_DATE=$(date -u -d '1 day' +%Y-%m-%dT%H:%M:%SZ)

echo "Generating SAS token with Service-Level constraints..."

az storage container generate-sas \
    --account-name $STORAGE_ACCOUNT \
    --name $CONTAINER_NAME \
    --permissions r \
    --expiry $EXPIRY_DATE \
    --https-only \
    --ip 10.1.0.0-10.1.255.255 \
    --output tsv

# TECHNICAL NOTE: The --ip constraint ensures that even if the token 
# is leaked to the internet, it remains useless as it's restricted 
# to the Spoke VNet's private address space.