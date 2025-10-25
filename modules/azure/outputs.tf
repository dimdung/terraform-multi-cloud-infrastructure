# Azure Module Outputs

# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Virtual Network Outputs
output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = azurerm_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = azurerm_subnet.private[*].id
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_endpoint" {
  description = "Primary endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.main.name
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Log Analytics Outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

# Application Insights Outputs
output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

# MySQL Database Outputs
output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = azurerm_mysql_server.main.name
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = azurerm_mysql_server.main.fqdn
}

output "mysql_database_name" {
  description = "Name of the MySQL database"
  value       = azurerm_mysql_database.main.name
}

# Virtual Machine Scale Set Outputs
output "vmss_name" {
  description = "Name of the VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.name
}

output "vmss_id" {
  description = "ID of the VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

# Application Gateway Outputs
output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.main.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the public IP"
  value       = azurerm_public_ip.main.fqdn
}

# Network Security Group Outputs
output "web_nsg_name" {
  description = "Name of the web NSG"
  value       = azurerm_network_security_group.web.name
}

output "web_nsg_id" {
  description = "ID of the web NSG"
  value       = azurerm_network_security_group.web.id
}

output "database_nsg_name" {
  description = "Name of the database NSG"
  value       = azurerm_network_security_group.database.name
}

output "database_nsg_id" {
  description = "ID of the database NSG"
  value       = azurerm_network_security_group.database.id
}
