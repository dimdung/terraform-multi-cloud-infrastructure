# Azure Module Variables

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Storage Configuration
variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS."
  }
}

# Key Vault Configuration
variable "key_vault_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = true
}

# Virtual Machine Configuration
variable "vm_sku" {
  description = "VM SKU for the scale set"
  type        = string
  default     = "Standard_B1s"
}

variable "vm_instances" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "vm_admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "vm_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

# Database Configuration
variable "db_sku_name" {
  description = "MySQL server SKU name"
  type        = string
  default     = "GP_Gen5_2"
}

variable "db_storage_mb" {
  description = "MySQL storage size in MB"
  type        = number
  default     = 51200
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_days" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
}

# Logging Configuration
variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
