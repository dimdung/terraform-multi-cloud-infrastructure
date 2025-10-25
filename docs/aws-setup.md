# AWS Setup Guide

## 🎯 Overview

This guide provides detailed instructions for setting up AWS infrastructure using Terraform.

## 📋 Prerequisites

- [ ] AWS Account with billing enabled
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] Appropriate IAM permissions

## 🔐 Step 1: AWS Account Setup

### 1.1: Create AWS Account
1. Go to [AWS Console](https://aws.amazon.com/)
2. Click "Create an AWS Account"
3. Follow the registration process
4. Verify your email address
5. Complete payment information

### 1.2: Enable Billing
1. Go to Billing & Cost Management
2. Set up billing alerts
3. Configure payment methods
4. Enable detailed billing

## 👤 Step 2: IAM User Setup

### 2.1: Create IAM User
1. Go to IAM Console
2. Click "Users" → "Create user"
3. Enter username: `terraform-user`
4. Select "Programmatic access"
5. Click "Next: Permissions"

### 2.2: Attach Policies
Attach the following policies:
- `AmazonEC2FullAccess`
- `AmazonRDSFullAccess`
- `AmazonS3FullAccess`
- `AmazonVPCFullAccess`
- `IAMFullAccess`
- `AmazonRoute53FullAccess`
- `AmazonCloudWatchFullAccess`

### 2.3: Create Access Keys
1. Click "Create access key"
2. Select "Application running outside AWS"
3. Download the CSV file
4. Store credentials securely

## 🔧 Step 3: AWS CLI Configuration

### 3.1: Install AWS CLI
```bash
# On macOS
brew install awscli

# On Ubuntu/Debian
sudo apt-get install awscli

# On Windows
# Download from: https://aws.amazon.com/cli/
```

### 3.2: Configure Credentials
```bash
aws configure
```

**Enter the following:**
- AWS Access Key ID: `your-access-key`
- AWS Secret Access Key: `your-secret-key`
- Default region name: `us-east-1`
- Default output format: `json`

### 3.3: Verify Configuration
```bash
aws sts get-caller-identity
```

**Expected output:**
```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

## 🏗️ Step 4: Terraform State Setup

### 4.1: Create S3 Bucket
```bash
# Create unique bucket name
BUCKET_NAME="terraform-state-$(date +%s)"

# Create S3 bucket
aws s3 mb s3://$BUCKET_NAME --region us-east-1
```

### 4.2: Enable Versioning
```bash
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled
```

### 4.3: Enable Encryption
```bash
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
```

### 4.4: Create DynamoDB Table
```bash
# Create table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

## 🚀 Step 5: Deploy Infrastructure

### 5.1: Navigate to AWS Environment
```bash
cd environments/dev/aws
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
project_name = "my-aws-project"
environment  = "dev"

# AWS Configuration
aws_region = "us-east-1"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]

# Compute
instance_type    = "t3.micro"
ami_id          = "ami-0c02fb55956c7d316" # Amazon Linux 2
min_size        = 1
max_size        = 3
desired_capacity = 2

# Database
db_instance_class           = "db.t3.micro"
db_allocated_storage        = 20
db_max_allocated_storage    = 100
db_name                     = "appdb"
db_username                 = "admin"
db_password                 = "your-secure-password"
db_backup_retention_period  = 7

# Logging
log_retention_days = 30

# Tags
tags = {
  Environment = "dev"
  Project     = "my-aws-project"
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
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "dev/aws/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
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
# Check EC2 instances
aws ec2 describe-instances

# Check RDS instances
aws rds describe-db-instances

# Check Load Balancers
aws elbv2 describe-load-balancers

# Check S3 buckets
aws s3 ls
```

### 6.2: Test Application
```bash
# Get Load Balancer DNS name
terraform output alb_dns_name

# Test HTTP connection
curl http://your-alb-dns-name
```

## 🧹 Step 7: Clean Up

### 7.1: Destroy Infrastructure
```bash
terraform destroy
```

### 7.2: Clean Up State Resources
```bash
# Delete S3 bucket
aws s3 rb s3://your-terraform-state-bucket --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-state-lock
```

## 🚨 Troubleshooting

### Common Issues

#### Issue 1: Access Denied
**Error:** `Error: Access Denied`
**Solution:** Check IAM permissions and policies

#### Issue 2: Region Mismatch
**Error:** `Error: region not found`
**Solution:** Verify AWS CLI region configuration

#### Issue 3: Resource Limits
**Error:** `Error: limit exceeded`
**Solution:** Check AWS service limits and quotas

### Debug Commands
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Check AWS configuration
aws configure list

# Verify permissions
aws sts get-caller-identity
```

## 📚 Additional Resources

- [AWS Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/)
- [Terraform AWS Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples)

---

**Next Steps:** After successful AWS deployment, you can:
1. Set up monitoring and alerting
2. Configure backup strategies
3. Implement security best practices
4. Optimize costs and performance
