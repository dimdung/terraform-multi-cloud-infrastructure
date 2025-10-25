#!/bin/bash

# AWS Setup Script for Multi-Cloud Terraform Project
# This script helps set up AWS credentials and resources for Terraform

set -e

echo "🚀 Setting up AWS for Multi-Cloud Terraform Project"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    echo "   Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Configure AWS credentials
echo "🔐 Configuring AWS credentials..."
aws configure

# Get AWS account information
echo "📊 AWS Account Information:"
aws sts get-caller-identity

# Create S3 bucket for Terraform state (if it doesn't exist)
BUCKET_NAME="terraform-state-$(date +%s)"
REGION="us-east-1"

echo "🪣 Creating S3 bucket for Terraform state: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
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

# Create DynamoDB table for state locking
TABLE_NAME="terraform-state-lock"
echo "🔒 Creating DynamoDB table for state locking: $TABLE_NAME"
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $REGION

# Wait for table to be created
echo "⏳ Waiting for DynamoDB table to be created..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

echo "✅ AWS setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Update your terraform.tfvars file with the following values:"
echo "   - aws_region = \"$REGION\""
echo "2. Update your backend.tf file with:"
echo "   - bucket = \"$BUCKET_NAME\""
echo "   - region = \"$REGION\""
echo "   - dynamodb_table = \"$TABLE_NAME\""
echo "3. Run 'terraform init' in your environment directory"
echo "4. Run 'terraform plan' to see what will be created"
echo "5. Run 'terraform apply' to create the infrastructure"
echo ""
echo "🔐 For GitHub Actions, add these secrets to your repository:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
