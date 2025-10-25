# Azure Setup Guide

## 🎯 Overview

This guide provides detailed instructions for setting up Azure infrastructure using Terraform.

## 📋 Prerequisites

- [ ] Azure Subscription with billing enabled
- [ ] Azure CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] Appropriate RBAC permissions

## 🔐 Step 1: Azure Account Setup

### 1.1: Create Azure Account
1. Go to [Azure Portal](https://portal.azure.com/)
2. Click "Create a resource"
3. Follow the registration process
4. Verify your email address
5. Complete payment information

### 1.2: Enable Billing
1. Go to Cost Management + Billing
2. Set up billing alerts
3. Configure payment methods
4. Enable detailed billing

## 👤 Step 2: Service Principal Setup

### 2.1: Create Service Principal
```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "terraform-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

### 2.2: Save Credentials
Save the JSON output securely:
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-client-secret",
  "subscriptionId": "12345678-1234-1234-1234-123456789012",
  "tenantId": "12345678-1234-1234-1234-123456789012",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

## 🔧 Step 3: Azure CLI Configuration

### 3.1: Install Azure CLI
```bash
# On macOS
brew install azure-cli

# On Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# On Windows
# Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
```

### 3.2: Login to Azure
```bash
az login
```

### 3.3: Set Subscription
```bash
# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "your-subscription-id"
```

### 3.4: Verify Configuration
```bash
az account show
```

**Expected output:**
```json
{
  "cloudName": "AzureCloud",
  "id": "12345678-1234-1234-1234-123456789012",
  "isDefault": true,
  "name": "Your Subscription Name",
  "state": "Enabled",
  "tenantId": "12345678-1234-1234-1234-123456789012",
  "user": {
    "name": "your-email@domain.com",
    "type": "user"
  }
}
```

## 🏗️ Step 4: Terraform State Setup

### 4.1: Create Resource Group
```bash
# Create resource group for Terraform state
az group create \
  --name terraform-state-rg \
  --location "East US"
```

### 4.2: Create Storage Account
```bash
# Create unique storage account name
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"

# Create storage account
az storage account create \
  --resource-group terraform-state-rg \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob
```

### 4.3: Create Container
```bash
# Create container for Terraform state
az storage container create \
  --name tfstate \
  --account-name $STORAGE_ACCOUNT_NAME
```

### 4.4: Get Storage Key
```bash
# Get storage account key
az storage account keys list \
  --resource-group terraform-state-rg \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' \
  --output tsv
```

## 🚀 Step 5: Deploy Infrastructure

### 5.1: Navigate to Azure Environment
```bash
cd environments/dev/azure
```

### 5.2: Configure Variables
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

**Update the following values:**
```hcl
# Project Configuration
project_name = "my-azure-project"
environment  = "dev"

# Azure Configuration
location = "East US"
resource_group_name = "rg-my-azure-project"

# Networking
vnet_address_space      = ["10.0.0.0/16"]
public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.10.0/24", "10.0.20.0/24"]

# Virtual Machine Configuration
vm_sku = "Standard_B1s"
vm_instances = 2
vm_admin_username = "azureuser"
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key"

# Database Configuration
db_sku_name = "GP_Gen5_2"
db_storage_mb = 51200
db_name = "appdb"
db_username = "admin"
db_password = "your-secure-password"
db_backup_retention_days = 7

# Storage Configuration
storage_replication_type = "LRS"

# Key Vault Configuration
key_vault_purge_protection = true

# Logging Configuration
log_retention_days = 30

# Tags
tags = {
  Environment = "dev"
  Project     = "my-azure-project"
  ManagedBy   = "terraform"
  Owner       = "your-name"
}
```

### 5.3: Configure Backend
```bash
# Edit backend configuration
nano backend.tf
```

**Update with your values:**
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name  = "your-storage-account-name"
    container_name        = "tfstate"
    key                   = "dev/azure/terraform.tfstate"
  }
}
```

### 5.4: Initialize Terraform
```bash
terraform init
```

### 5.5: Plan Deployment
```bash
terraform plan
```

### 5.6: Apply Configuration
```bash
terraform apply
```

## 🔍 Step 6: Verify Deployment

### 6.1: Check Resources
```bash
# Check Virtual Machines
az vm list

# Check MySQL Servers
az mysql server list

# Check Application Gateways
az network application-gateway list

# Check Storage Accounts
az storage account list
```

### 6.2: Test Application
```bash
# Get Application Gateway IP
terraform output public_ip_address

# Test HTTP connection
curl http://your-app-gateway-ip
```

## 🧹 Step 7: Clean Up

### 7.1: Destroy Infrastructure
```bash
terraform destroy
```

### 7.2: Clean Up State Resources
```bash
# Delete resource group
az group delete --name terraform-state-rg --yes

# Delete service principal
az ad sp delete --id "your-service-principal-id"
```

## 🚨 Troubleshooting

### Common Issues

#### Issue 1: Authentication Failed
**Error:** `Error: Failed to get existing workspaces`
**Solution:** Check Azure CLI login and subscription

#### Issue 2: Access Denied
**Error:** `Error: Access Denied`
**Solution:** Check RBAC permissions and service principal roles

#### Issue 3: Resource Not Found
**Error:** `Error: resource not found`
**Solution:** Verify resource group and location

### Debug Commands
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Check Azure configuration
az account show

# Verify permissions
az role assignment list --assignee "your-service-principal-id"
```

## 📚 Additional Resources

- [Azure Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Terraform Azure Examples](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples)

---

**Next Steps:** After successful Azure deployment, you can:
1. Set up monitoring and alerting
2. Configure backup strategies
3. Implement security best practices
4. Optimize costs and performance
