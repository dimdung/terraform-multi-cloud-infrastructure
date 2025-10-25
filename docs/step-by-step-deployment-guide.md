# Step-by-Step Deployment Guide

## 🎯 Overview

This guide will walk you through deploying infrastructure across AWS, Azure, and Google Cloud Platform (GCP) using Terraform. Follow these steps carefully to ensure a successful deployment.

## 📋 Prerequisites

Before starting, ensure you have the following installed and configured:

### Required Software
- [ ] **Terraform** >= 1.0 ([Download here](https://www.terraform.io/downloads.html))
- [ ] **Git** ([Download here](https://git-scm.com/downloads))
- [ ] **Cloud CLI Tools** (choose based on your target cloud):
  - [ ] **AWS CLI** ([Download here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
  - [ ] **Azure CLI** ([Download here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
  - [ ] **Google Cloud CLI** ([Download here](https://cloud.google.com/sdk/docs/install))

### Required Accounts
- [ ] **AWS Account** with appropriate permissions
- [ ] **Azure Subscription** with appropriate permissions
- [ ] **Google Cloud Project** with billing enabled

---

## 🚀 Step 1: Clone the Repository

```bash
# Clone the repository
git clone <your-repository-url>
cd terraform-multi-cloud-infrastructure

# Verify the project structure
ls -la
```

**Expected Output:**
```
├── .github/
├── modules/
├── environments/
├── scripts/
├── docs/
└── README.md
```

---

## 🔧 Step 2: Choose Your Cloud Provider

You can deploy to one or multiple cloud providers. Choose your target:

### Option A: Deploy to AWS Only
- Skip to [Step 3A: AWS Setup](#step-3a-aws-setup)

### Option B: Deploy to Azure Only
- Skip to [Step 3B: Azure Setup](#step-3b-azure-setup)

### Option C: Deploy to GCP Only
- Skip to [Step 3C: GCP Setup](#step-3c-gcp-setup)

### Option D: Deploy to Multiple Clouds
- Follow all setup steps (3A, 3B, 3C)

---

## ☁️ Step 3A: AWS Setup

### 3A.1: Install AWS CLI
```bash
# Check if AWS CLI is installed
aws --version

# If not installed, install it
# On macOS:
brew install awscli

# On Ubuntu/Debian:
sudo apt-get install awscli

# On Windows:
# Download from: https://aws.amazon.com/cli/
```

### 3A.2: Configure AWS Credentials
```bash
# Configure AWS credentials
aws configure

# You'll be prompted for:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### 3A.3: Verify AWS Access
```bash
# Test AWS connection
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/your-username"
# }
```

### 3A.4: Run AWS Setup Script
```bash
# Make the script executable
chmod +x scripts/setup-aws.sh

# Run the AWS setup script
./scripts/setup-aws.sh
```

**What this script does:**
- Creates S3 bucket for Terraform state
- Creates DynamoDB table for state locking
- Enables versioning and encryption
- Provides configuration instructions

### 3A.5: Configure AWS Environment
```bash
# Navigate to AWS environment
cd environments/dev/aws

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
nano terraform.tfvars
```

**Update these values in `terraform.tfvars`:**
```hcl
# Project Configuration
project_name = "my-aws-project"
environment  = "dev"

# AWS Configuration
aws_region = "us-east-1"

# Database Configuration
db_password = "your-secure-password-here"

# Tags
tags = {
  Environment = "dev"
  Project     = "my-aws-project"
  ManagedBy   = "terraform"
  Owner       = "your-name"
}
```

### 3A.6: Configure AWS Backend
```bash
# Edit the backend configuration
nano backend.tf
```

**Update the backend.tf file:**
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "dev/aws/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## 🔵 Step 3B: Azure Setup

### 3B.1: Install Azure CLI
```bash
# Check if Azure CLI is installed
az --version

# If not installed, install it
# On macOS:
brew install azure-cli

# On Ubuntu/Debian:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# On Windows:
# Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
```

### 3B.2: Login to Azure
```bash
# Login to Azure
az login

# This will open a browser window for authentication
# After successful login, you'll see your subscription information
```

### 3B.3: Verify Azure Access
```bash
# Check your Azure account
az account show

# List available subscriptions
az account list --output table
```

### 3B.4: Run Azure Setup Script
```bash
# Make the script executable
chmod +x scripts/setup-azure.sh

# Run the Azure setup script
./scripts/setup-azure.sh
```

**What this script does:**
- Creates resource group for Terraform state
- Creates storage account for state files
- Creates container for state storage
- Provides configuration instructions

### 3B.5: Configure Azure Environment
```bash
# Navigate to Azure environment
cd environments/dev/azure

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
nano terraform.tfvars
```

**Update these values in `terraform.tfvars`:**
```hcl
# Project Configuration
project_name = "my-azure-project"
environment  = "dev"

# Azure Configuration
location = "East US"
resource_group_name = "rg-my-azure-project"

# Database Configuration
db_password = "your-secure-password-here"

# VM Configuration
vm_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... your-public-key"

# Tags
tags = {
  Environment = "dev"
  Project     = "my-azure-project"
  ManagedBy   = "terraform"
  Owner       = "your-name"
}
```

### 3B.6: Configure Azure Backend
```bash
# Edit the backend configuration
nano backend.tf
```

**Update the backend.tf file:**
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

---

## 🌐 Step 3C: GCP Setup

### 3C.1: Install Google Cloud CLI
```bash
# Check if gcloud is installed
gcloud --version

# If not installed, install it
# On macOS:
brew install google-cloud-sdk

# On Ubuntu/Debian:
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# On Windows:
# Download from: https://cloud.google.com/sdk/docs/install
```

### 3C.2: Login to Google Cloud
```bash
# Login to Google Cloud
gcloud auth login

# This will open a browser window for authentication
# After successful login, set your project
gcloud config set project YOUR_PROJECT_ID
```

### 3C.3: Verify GCP Access
```bash
# Check your GCP project
gcloud config get-value project

# List available projects
gcloud projects list
```

### 3C.4: Run GCP Setup Script
```bash
# Make the script executable
chmod +x scripts/setup-gcp.sh

# Run the GCP setup script
./scripts/setup-gcp.sh
```

**What this script does:**
- Enables required GCP APIs
- Creates storage bucket for Terraform state
- Creates service account for Terraform
- Grants necessary permissions
- Creates service account key

### 3C.5: Configure GCP Environment
```bash
# Navigate to GCP environment
cd environments/dev/gcp

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
nano terraform.tfvars
```

**Update these values in `terraform.tfvars`:**
```hcl
# Project Configuration
project_name = "my-gcp-project"
environment  = "dev"

# GCP Configuration
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"

# Database Configuration
db_password = "your-secure-password-here"

# Tags
tags = {
  Environment = "dev"
  Project     = "my-gcp-project"
  ManagedBy   = "terraform"
  Owner       = "your-name"
}
```

### 3C.6: Configure GCP Backend
```bash
# Edit the backend configuration
nano backend.tf
```

**Update the backend.tf file:**
```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket-name"
    prefix = "dev/gcp/terraform/state"
  }
}
```

---

## ✅ Step 4: Validate Configuration

### 4.1: Run Validation Script
```bash
# Navigate back to project root
cd ../../../

# Run the validation script
./scripts/validate.sh
```

**Expected Output:**
```
🔍 Validating Multi-Cloud Terraform Project
✅ Terraform is installed
📋 Terraform version: 1.6.0
🔍 Validating AWS configuration in environments/dev/aws...
✅ Terraform validation passed for AWS
✅ Terraform formatting is correct for AWS
🔍 Validating Azure configuration in environments/dev/azure...
✅ Terraform validation passed for Azure
✅ Terraform formatting is correct for Azure
🔍 Validating GCP configuration in environments/dev/gcp...
✅ Terraform validation passed for GCP
✅ Terraform formatting is correct for GCP
🎉 All validations passed! Your multi-cloud Terraform project is ready to deploy.
```

### 4.2: Manual Validation (Optional)
```bash
# Validate AWS configuration
cd environments/dev/aws
terraform init
terraform validate
terraform plan

# Validate Azure configuration
cd ../azure
terraform init
terraform validate
terraform plan

# Validate GCP configuration
cd ../gcp
terraform init
terraform validate
terraform plan
```

---

## 🚀 Step 5: Deploy Infrastructure

### 5.1: Deploy to AWS
```bash
# Navigate to AWS environment
cd environments/dev/aws

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

**Expected Output:**
```
Plan: 15 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "terraform-aws-demo-alb-1234567890.us-east-1.elb.amazonaws.com"
vpc_id = "vpc-1234567890abcdef0"
...
```

### 5.2: Deploy to Azure
```bash
# Navigate to Azure environment
cd ../azure

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

### 5.3: Deploy to GCP
```bash
# Navigate to GCP environment
cd ../gcp

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Type 'yes' when prompted
```

---

## 🔍 Step 6: Verify Deployment

### 6.1: Check AWS Resources
```bash
# Check AWS resources
aws ec2 describe-instances
aws rds describe-db-instances
aws elbv2 describe-load-balancers
```

### 6.2: Check Azure Resources
```bash
# Check Azure resources
az vm list
az mysql server list
az network lb list
```

### 6.3: Check GCP Resources
```bash
# Check GCP resources
gcloud compute instances list
gcloud sql instances list
gcloud compute forwarding-rules list
```

---

## 🧹 Step 7: Clean Up (Optional)

**⚠️ Warning: This will destroy all resources and may incur costs!**

### 7.1: Destroy AWS Resources
```bash
cd environments/dev/aws
terraform destroy
```

### 7.2: Destroy Azure Resources
```bash
cd ../azure
terraform destroy
```

### 7.3: Destroy GCP Resources
```bash
cd ../gcp
terraform destroy
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Authentication Errors
**Problem:** `Error: Failed to get existing workspaces`
**Solution:**
```bash
# Check your credentials
aws sts get-caller-identity  # For AWS
az account show              # For Azure
gcloud auth list            # For GCP
```

#### Issue 2: Resource Already Exists
**Problem:** `Error: resource already exists`
**Solution:**
```bash
# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Or destroy and recreate
terraform destroy
terraform apply
```

#### Issue 3: Permission Denied
**Problem:** `Error: Access Denied`
**Solution:**
- Check IAM permissions for AWS
- Check Azure RBAC assignments
- Check GCP IAM roles

#### Issue 4: Terraform State Issues
**Problem:** `Error: state file is locked`
**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

### Getting Help

1. **Check Terraform Documentation**: [https://www.terraform.io/docs](https://www.terraform.io/docs)
2. **Cloud Provider Documentation**:
   - [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
   - [Azure Terraform Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
   - [GCP Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
3. **Project Issues**: Create an issue in the repository

---

## 📚 Next Steps

After successful deployment:

1. **Monitor Resources**: Set up monitoring and alerting
2. **Backup Strategy**: Implement backup and disaster recovery
3. **Security Review**: Conduct security assessment
4. **Cost Optimization**: Review and optimize costs
5. **Documentation**: Document your specific configuration

---

## 🎉 Congratulations!

You have successfully deployed infrastructure across multiple cloud providers using Terraform! 

**What you've accomplished:**
- ✅ Set up multi-cloud infrastructure
- ✅ Deployed production-ready resources
- ✅ Implemented security best practices
- ✅ Created automated deployment pipeline

**Next steps:**
- Monitor your infrastructure
- Set up alerts and notifications
- Implement backup strategies
- Plan for disaster recovery

---

*This guide provides a comprehensive walkthrough for deploying multi-cloud infrastructure. For additional support, refer to the project documentation or create an issue in the repository.*
