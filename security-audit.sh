#!/bin/bash

# Fetching values dynamically from Terraform outputs
STORAGE_NAME=$(terraform output -raw storage_account_name)
RG_NAME=$(terraform output -raw resource_group_name)

echo "--------------------------------------------------------"
echo "SECURITY AUDIT: $STORAGE_NAME"
echo "--------------------------------------------------------"

# 1. Verify Public Network Access status
echo "[CHECK] Public Network Access..."
STATUS=$(az storage account show --name $STORAGE_NAME --resource-group $RG_NAME --query publicNetworkAccess -o tsv)

if [ "$STATUS" == "Disabled" ]; then
    echo "SUCCESS: Public Access is Disabled (Zero Trust Compliant)."
else
    echo "WARNING: Public Access is still enabled!"
fi

# 2. Verify Minimum TLS Version
echo "[CHECK] Minimum TLS Version..."
TLS=$(az storage account show --name $STORAGE_NAME --resource-group $RG_NAME --query minimumTlsVersion -o tsv)
echo "RESULT: TLS version is set to $TLS"

# 3. Verify Immutability Policy status
echo "[CHECK] Container Immutability Policy..."
az storage container immutability-policy show --account-name $STORAGE_NAME --container-name legal-audit-logs --query "immutabilityPeriodSinceCreationInDays" -o table

echo "--------------------------------------------------------"
echo "AUDIT COMPLETE"