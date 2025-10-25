#!/bin/bash

# Azure Setup Script for Multi-Cloud Terraform Project
# This script helps set up Azure credentials and resources for Terraform

set -e

echo "🚀 Setting up Azure for Multi-Cloud Terraform Project"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    echo "   Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Login to Azure
echo "🔐 Logging into Azure..."
az login

# Get Azure account information
echo "📊 Azure Account Information:"
az account show

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "📋 Subscription ID: $SUBSCRIPTION_ID"

# Create resource group for Terraform state
RESOURCE_GROUP_NAME="terraform-state-rg"
LOCATION="East US"
STORAGE_ACCOUNT_NAME="tfstate$(date +%s)"
CONTAINER_NAME="tfstate"

echo "🏗️ Creating resource group for Terraform state: $RESOURCE_GROUP_NAME"
az group create \
    --name $RESOURCE_GROUP_NAME \
    --location "$LOCATION"

# Create storage account for Terraform state
echo "🪣 Creating storage account for Terraform state: $STORAGE_ACCOUNT_NAME"
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --encryption-services blob

# Create container for Terraform state
echo "📦 Creating container for Terraform state: $CONTAINER_NAME"
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME

# Get storage account key
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' \
    --output tsv)

echo "✅ Azure setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Update your terraform.tfvars file with the following values:"
echo "   - location = \"$LOCATION\""
echo "   - resource_group_name = \"$RESOURCE_GROUP_NAME\""
echo "2. Update your backend.tf file with:"
echo "   - resource_group_name = \"$RESOURCE_GROUP_NAME\""
echo "   - storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "   - container_name = \"$CONTAINER_NAME\""
echo "   - key = \"terraform.tfstate\""
echo "3. Run 'terraform init' in your environment directory"
echo "4. Run 'terraform plan' to see what will be created"
echo "5. Run 'terraform apply' to create the infrastructure"
echo ""
echo "🔐 For GitHub Actions, create a Service Principal:"
echo "   az ad sp create-for-rbac --name \"terraform-github-actions\" \\"
echo "     --role contributor \\"
echo "     --scopes /subscriptions/$SUBSCRIPTION_ID \\"
echo "     --sdk-auth"
echo ""
echo "   Then add the JSON output as the AZURE_CREDENTIALS secret in GitHub."
