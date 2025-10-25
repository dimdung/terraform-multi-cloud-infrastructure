#!/bin/bash

# GCP Setup Script for Multi-Cloud Terraform Project
# This script helps set up GCP credentials and resources for Terraform

set -e

echo "🚀 Setting up GCP for Multi-Cloud Terraform Project"

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud CLI is not installed. Please install it first."
    echo "   Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Login to GCP
echo "🔐 Logging into GCP..."
gcloud auth login

# Get GCP project information
echo "📊 GCP Project Information:"
gcloud config get-value project

# Set project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No GCP project is set. Please set a project:"
    echo "   gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "📋 Project ID: $PROJECT_ID"

# Enable required APIs
echo "🔧 Enabling required GCP APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable logging.googleapis.com

# Create storage bucket for Terraform state
BUCKET_NAME="terraform-state-$(date +%s)"
REGION="us-central1"

echo "🪣 Creating storage bucket for Terraform state: $BUCKET_NAME"
gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$BUCKET_NAME

# Enable versioning on the bucket
gsutil versioning set on gs://$BUCKET_NAME

# Create service account for Terraform
SERVICE_ACCOUNT_NAME="terraform-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "👤 Creating service account for Terraform: $SERVICE_ACCOUNT_EMAIL"
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="Terraform Service Account" \
    --description="Service account for Terraform automation"

# Grant necessary roles to the service account
echo "🔐 Granting roles to service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/sql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/logging.admin"

# Create and download service account key
KEY_FILE="terraform-sa-key.json"
echo "🔑 Creating service account key..."
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "✅ GCP setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Update your terraform.tfvars file with the following values:"
echo "   - project_id = \"$PROJECT_ID\""
echo "   - region = \"$REGION\""
echo "2. Update your backend.tf file with:"
echo "   - bucket = \"$BUCKET_NAME\""
echo "   - prefix = \"terraform/state\""
echo "3. Run 'terraform init' in your environment directory"
echo "4. Run 'terraform plan' to see what will be created"
echo "5. Run 'terraform apply' to create the infrastructure"
echo ""
echo "🔐 For GitHub Actions, add the following secret to your repository:"
echo "   - GCP_SA_KEY: Contents of $KEY_FILE"
echo ""
echo "⚠️  Keep the service account key file secure and do not commit it to version control!"
echo "   The key file has been saved as: $KEY_FILE"
