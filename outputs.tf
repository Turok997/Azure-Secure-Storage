output "storage_account_name" {
  description = "The name of the deployed storage account"
  value       = azurerm_storage_account.secure_storage.name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "private_endpoint_ip" {
  description = "Internal IP address of the storage account"
  value       = azurerm_private_endpoint.st_pe.private_service_connection[0].private_ip_address
}