#!/bin/bash
# simple audit script for the Secure Storage Enclave

# Variables from Terraform (or set manually)
SA_NAME=$(terraform output -raw storage_account_name)
RG_NAME=$(terraform output -raw resource_group_name)

echo "--- STARTING SECURITY AUDIT FOR $SA_NAME ---"

# 1. Check: public Network Access
PUBLIC_ACCESS=$(az storage account show --name $SA_NAME --resource-group $RG_NAME --query publicNetworkAccess -o tsv)
echo "[*] Public Network Access: $PUBLIC_ACCESS"

# 2. Check: TLS Version (1.2)
TLS_VER=$(az storage account show --name $SA_NAME --resource-group $RG_NAME --query minimumTlsVersion -o tsv)
echo "[*] Minimum TLS Version: $TLS_VER"

# 3. Check: Immutability Policy on the 'legal' Container
echo "[*] Checking Immutability Policy on 'legal-audit-logs'..."
az storage container immutability-policy show --account-name $SA_NAME --container-name legal-audit-logs

echo "--- AUDIT COMPLETE ---"