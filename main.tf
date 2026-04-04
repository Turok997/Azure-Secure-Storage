# --- Provider Configuration ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- Resource Group ---
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name # VARIABLE
  location = var.location            # VARIABLE
}

# --- Networking: Hub and Spoke ---
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-we-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-we-01"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "endpoint_subnet" {
  name                 = "snet-endpoints-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

# VNet Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

# --- Storage Configuration ---
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "secure_storage" {
  name                     = "${var.storage_account_prefix}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
  shared_access_key_enabled      = true 
  
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = [var.my_ip_address] # VARIABLE aus terraform.tfvars
  }
}

resource "azurerm_storage_container" "docs" {
  name                  = "internal-data"
  storage_account_name  = azurerm_storage_account.secure_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "legal" {
  name                  = "legal-audit-logs"
  storage_account_name  = azurerm_storage_account.secure_storage.name
  container_access_type = "private"
}

# --- Private Link and DNS ---
resource "azurerm_private_endpoint" "st_pe" {
  name                = "pe-storage-blob"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

  private_service_connection {
    name                           = "psc-storage-blob"
    private_connection_resource_id = azurerm_storage_account.secure_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "link-spoke-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

resource "azurerm_private_dns_a_record" "dns_a" {
  name                = azurerm_storage_account.secure_storage.name
  zone_name           = azurerm_private_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.st_pe.private_service_connection[0].private_ip_address]
}

# --- Storage Container Policy ---
resource "azurerm_storage_container_immutability_policy" "immutability" {
  # WICHTIG: .resource_manager_id nutzen für Control Plane Zugriff
  storage_container_resource_manager_id = azurerm_storage_container.legal.resource_manager_id
  immutability_period_in_days           = var.immutability_period # VARIABLE
}