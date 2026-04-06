output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the generated Storage Account"
  value       = azurerm_storage_account.secure_storage.name
}

output "private_endpoint_ip" {
  description = "Internal IP of the Storage Account (Private Link)"
  value       = azurerm_private_endpoint.st_pe.private_service_connection[0].private_ip_address
}

output "storage_blob_endpoint" {
  description = "Primary Blob Endpoint (for scripts)"
  value       = azurerm_storage_account.secure_storage.primary_blob_endpoint
}