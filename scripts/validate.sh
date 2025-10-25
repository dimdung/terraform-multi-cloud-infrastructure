#!/bin/bash

# Validation Script for Multi-Cloud Terraform Project
# This script validates the Terraform configuration across all cloud providers

set -e

echo "🔍 Validating Multi-Cloud Terraform Project"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to validate Terraform configuration
validate_terraform() {
    local dir=$1
    local provider=$2
    
    echo "🔍 Validating $provider configuration in $dir..."
    
    cd "$dir"
    
    # Check if Terraform is initialized
    if [ ! -d ".terraform" ]; then
        echo -e "${YELLOW}⚠️  Terraform not initialized in $dir. Running terraform init...${NC}"
        terraform init -backend=false
    fi
    
    # Validate configuration
    if terraform validate; then
        print_status 0 "Terraform validation passed for $provider"
    else
        print_status 1 "Terraform validation failed for $provider"
        return 1
    fi
    
    # Check formatting
    if terraform fmt -check; then
        print_status 0 "Terraform formatting is correct for $provider"
    else
        echo -e "${YELLOW}⚠️  Terraform formatting issues found for $provider. Run 'terraform fmt' to fix.${NC}"
    fi
    
    cd - > /dev/null
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed. Please install it first.${NC}"
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo -e "${GREEN}✅ Terraform is installed${NC}"

# Get Terraform version
TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
echo "📋 Terraform version: $TF_VERSION"

# Validate AWS configuration
if [ -d "environments/dev/aws" ]; then
    validate_terraform "environments/dev/aws" "AWS"
    AWS_VALID=$?
else
    echo -e "${YELLOW}⚠️  AWS environment directory not found${NC}"
    AWS_VALID=1
fi

# Validate Azure configuration
if [ -d "environments/dev/azure" ]; then
    validate_terraform "environments/dev/azure" "Azure"
    AZURE_VALID=$?
else
    echo -e "${YELLOW}⚠️  Azure environment directory not found${NC}"
    AZURE_VALID=1
fi

# Validate GCP configuration
if [ -d "environments/dev/gcp" ]; then
    validate_terraform "environments/dev/gcp" "GCP"
    GCP_VALID=$?
else
    echo -e "${YELLOW}⚠️  GCP environment directory not found${NC}"
    GCP_VALID=1
fi

# Validate modules
echo "🔍 Validating Terraform modules..."

# Validate AWS module
if [ -d "modules/aws" ]; then
    validate_terraform "modules/aws" "AWS Module"
    AWS_MODULE_VALID=$?
else
    echo -e "${YELLOW}⚠️  AWS module directory not found${NC}"
    AWS_MODULE_VALID=1
fi

# Validate Azure module
if [ -d "modules/azure" ]; then
    validate_terraform "modules/azure" "Azure Module"
    AZURE_MODULE_VALID=$?
else
    echo -e "${YELLOW}⚠️  Azure module directory not found${NC}"
    AZURE_MODULE_VALID=1
fi

# Validate GCP module
if [ -d "modules/gcp" ]; then
    validate_terraform "modules/gcp" "GCP Module"
    GCP_MODULE_VALID=$?
else
    echo -e "${YELLOW}⚠️  GCP module directory not found${NC}"
    GCP_MODULE_VALID=1
fi

# Summary
echo ""
echo "📊 Validation Summary:"
echo "======================"

if [ $AWS_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ AWS Environment: Valid${NC}"
else
    echo -e "${RED}❌ AWS Environment: Invalid${NC}"
fi

if [ $AZURE_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ Azure Environment: Valid${NC}"
else
    echo -e "${RED}❌ Azure Environment: Invalid${NC}"
fi

if [ $GCP_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ GCP Environment: Valid${NC}"
else
    echo -e "${RED}❌ GCP Environment: Invalid${NC}"
fi

if [ $AWS_MODULE_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ AWS Module: Valid${NC}"
else
    echo -e "${RED}❌ AWS Module: Invalid${NC}"
fi

if [ $AZURE_MODULE_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ Azure Module: Valid${NC}"
else
    echo -e "${RED}❌ Azure Module: Invalid${NC}"
fi

if [ $GCP_MODULE_VALID -eq 0 ]; then
    echo -e "${GREEN}✅ GCP Module: Valid${NC}"
else
    echo -e "${RED}❌ GCP Module: Invalid${NC}"
fi

# Overall result
TOTAL_VALID=$((AWS_VALID + AZURE_VALID + GCP_VALID + AWS_MODULE_VALID + AZURE_MODULE_VALID + GCP_MODULE_VALID))

if [ $TOTAL_VALID -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All validations passed! Your multi-cloud Terraform project is ready to deploy.${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some validations failed. Please fix the issues above before deploying.${NC}"
    exit 1
fi
