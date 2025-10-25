# Quick Start Guide

## 🚀 Deploy Infrastructure in 5 Minutes

This guide will get you up and running quickly with minimal configuration.

## Prerequisites

- [ ] Terraform >= 1.0 installed
- [ ] Cloud provider CLI installed (AWS CLI, Azure CLI, or gcloud)
- [ ] Cloud provider account with billing enabled

## Option 1: AWS Quick Deploy

### 1. Configure AWS
```bash
aws configure
# Enter your AWS credentials when prompted
```

### 2. Run Setup Script
```bash
./scripts/setup-aws.sh
```

### 3. Deploy Infrastructure
```bash
cd environments/dev/aws
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

## Option 2: Azure Quick Deploy

### 1. Login to Azure
```bash
az login
```

### 2. Run Setup Script
```bash
./scripts/setup-azure.sh
```

### 3. Deploy Infrastructure
```bash
cd environments/dev/azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

## Option 3: GCP Quick Deploy

### 1. Login to GCP
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Run Setup Script
```bash
./scripts/setup-gcp.sh
```

### 3. Deploy Infrastructure
```bash
cd environments/dev/gcp
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

## 🎯 What Gets Created

### AWS Resources
- VPC with public/private subnets
- Application Load Balancer
- Auto Scaling Group with EC2 instances
- RDS MySQL database
- S3 bucket for application data
- CloudWatch logging

### Azure Resources
- Virtual Network with subnets
- Application Gateway
- Virtual Machine Scale Set
- Azure Database for MySQL
- Storage Account
- Application Insights

### GCP Resources
- VPC Network with subnets
- Load Balancer
- Managed Instance Group
- Cloud SQL MySQL
- Cloud Storage bucket
- Cloud Logging

## 🔧 Configuration

Edit `terraform.tfvars` in your chosen environment:

```hcl
# Project Configuration
project_name = "my-project"
environment  = "dev"

# Database Configuration
db_password = "your-secure-password"

# Tags
tags = {
  Environment = "dev"
  Project     = "my-project"
  Owner       = "your-name"
}
```

## 🧹 Clean Up

To destroy all resources:
```bash
terraform destroy
```

## 🆘 Need Help?

- Check the [Step-by-Step Guide](step-by-step-deployment-guide.md) for detailed instructions
- Review the [Troubleshooting Guide](troubleshooting-guide.md) for common issues
- Create an issue in the repository for support

---

**Ready to deploy? Choose your cloud provider and follow the steps above!** 🚀
