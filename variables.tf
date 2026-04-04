variable "resource_group_name" {
  description = "Name der Resource Group"
  type        = string
  default     = "rg-secure-storage-enclave"
}

variable "location" {
  description = "Azure Region für das Deployment"
  type        = string
  default     = "West Europe"
}

variable "storage_account_prefix" {
  description = "Präfix für den Storage Account Namen"
  type        = string
  default     = "stsecure"
}

variable "my_ip_address" {
  description = "Deine öffentliche IPv4-Adresse für den Firewall-Zugriff (z.B. 93.206.xx.xx)"
  type        = string
}

variable "immutability_period" {
  description = "Anzahl der Tage für den Löschschutz"
  type        = number
  default     = 7
}