# GCP Setup Guide

## 🎯 Overview

This guide provides detailed instructions for setting up Google Cloud Platform (GCP) infrastructure using Terraform.

## 📋 Prerequisites

- [ ] Google Cloud Project with billing enabled
- [ ] Google Cloud CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] Appropriate IAM permissions

## 🔐 Step 1: GCP Account Setup

### 1.1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name: `my-terraform-project`
4. Click "Create"
5. Note the Project ID

### 1.2: Enable Billing
1. Go to Billing
2. Link a billing account
3. Set up billing alerts
4. Configure payment methods

## 👤 Step 2: Service Account Setup

### 2.1: Create Service Account
```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Create service account
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" \
  --description="Service account for Terraform automation"
```

### 2.2: Grant Required Roles
```bash
# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/sql.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.admin"
```

### 2.3: Create Service Account Key
```bash
# Create and download service account key
gcloud iam service-accounts keys create terraform-sa-key.json \
  --iam-account=terraform-sa@$PROJECT_ID.iam.gserviceaccount.com
```

## 🔧 Step 3: Google Cloud CLI Configuration

### 3.1: Install Google Cloud CLI
```bash
# On macOS
brew install google-cloud-sdk

# On Ubuntu/Debian
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# On Windows
# Download from: https://cloud.google.com/sdk/docs/install
```

### 3.2: Login to Google Cloud
```bash
gcloud auth login
```

### 3.3: Set Project
```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Verify configuration
gcloud config get-value project
```

### 3.4: Verify Configuration
```bash
gcloud auth list
```

**Expected output:**
```
Credentialed Accounts
ACTIVE  ACCOUNT
*       your-email@domain.com
```

## 🏗️ Step 4: Terraform State Setup

### 4.1: Enable Required APIs
```bash
# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable logging.googleapis.com
```

### 4.2: Create Storage Bucket
```bash
# Create unique bucket name
BUCKET_NAME="terraform-state-$(date +%s)"

# Create storage bucket
gsutil mb -p $PROJECT_ID -c STANDARD -l us-central1 gs://$BUCKET_NAME
```

### 4.3: Enable Versioning
```bash
gsutil versioning set on gs://$BUCKET_NAME
```

### 4.4: Set Bucket Permissions
```bash
# Set bucket permissions
gsutil iam ch serviceAccount:terraform-sa@$PROJECT_ID.iam.gserviceaccount.com:objectAdmin gs://$BUCKET_NAME
```

## 🚀 Step 5: Deploy Infrastructure

### 5.1: Navigate to GCP Environment
```bash
cd environments/dev/gcp
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
project_name = "my-gcp-project"
environment  = "dev"

# GCP Configuration
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"

# Networking
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# Compute Configuration
machine_type = "e2-micro"
image        = "ubuntu-2004-lts"
disk_size_gb = 20
min_replicas = 1
max_replicas = 3

# Database Configuration
db_machine_type = "db-f1-micro"
db_name         = "appdb"
db_username     = "admin"
db_password     = "your-secure-password"

# Storage Configuration
storage_class = "STANDARD"

# Monitoring Configuration
monitoring_enabled = true

# Tags
tags = {
  Environment = "dev"
  Project     = "my-gcp-project"
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
  backend "gcs" {
    bucket = "your-terraform-state-bucket-name"
    prefix = "dev/gcp/terraform/state"
  }
}
```

### 5.4: Set Environment Variables
```bash
# Set Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS="path/to/terraform-sa-key.json"

# Or use gcloud auth
gcloud auth application-default login
```

### 5.5: Initialize Terraform
```bash
terraform init
```

### 5.6: Plan Deployment
```bash
terraform plan
```

### 5.7: Apply Configuration
```bash
terraform apply
```

## 🔍 Step 6: Verify Deployment

### 6.1: Check Resources
```bash
# Check Compute Engine instances
gcloud compute instances list

# Check Cloud SQL instances
gcloud sql instances list

# Check Load Balancers
gcloud compute forwarding-rules list

# Check Storage Buckets
gsutil ls
```

### 6.2: Test Application
```bash
# Get Load Balancer IP
terraform output load_balancer_ip

# Test HTTP connection
curl http://your-load-balancer-ip
```

## 🧹 Step 7: Clean Up

### 7.1: Destroy Infrastructure
```bash
terraform destroy
```

### 7.2: Clean Up State Resources
```bash
# Delete storage bucket
gsutil rm -r gs://$BUCKET_NAME

# Delete service account
gcloud iam service-accounts delete terraform-sa@$PROJECT_ID.iam.gserviceaccount.com

# Delete service account key
rm terraform-sa-key.json
```

## 🚨 Troubleshooting

### Common Issues

#### Issue 1: Authentication Failed
**Error:** `Error: Failed to get existing workspaces`
**Solution:** Check Google Cloud authentication and credentials

#### Issue 2: Access Denied
**Error:** `Error: Access Denied`
**Solution:** Check IAM roles and service account permissions

#### Issue 3: API Not Enabled
**Error:** `Error: API not enabled`
**Solution:** Enable required APIs in Google Cloud Console

### Debug Commands
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Check Google Cloud configuration
gcloud config list

# Verify permissions
gcloud projects get-iam-policy $PROJECT_ID
```

## 📚 Additional Resources

- [GCP Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud CLI Documentation](https://cloud.google.com/sdk/docs)
- [Terraform GCP Examples](https://github.com/hashicorp/terraform-provider-google/tree/main/examples)

---

**Next Steps:** After successful GCP deployment, you can:
1. Set up monitoring and alerting
2. Configure backup strategies
3. Implement security best practices
4. Optimize costs and performance
