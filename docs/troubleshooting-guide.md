# Troubleshooting Guide

## 🚨 Common Issues and Solutions

This guide helps you resolve common issues when deploying multi-cloud infrastructure.

## 🔐 Authentication Issues

### AWS Authentication Problems

**Error:** `Error: No valid credential sources found`

**Solutions:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# If not configured, run:
aws configure

# Or set environment variables:
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Error:** `Error: Access Denied`

**Solutions:**
- Check IAM permissions
- Ensure user has required policies:
  - `AmazonEC2FullAccess`
  - `AmazonRDSFullAccess`
  - `AmazonS3FullAccess`
  - `IAMFullAccess`

### Azure Authentication Problems

**Error:** `Error: Failed to get existing workspaces`

**Solutions:**
```bash
# Check Azure login
az account show

# If not logged in:
az login

# Set correct subscription:
az account set --subscription "your-subscription-id"
```

**Error:** `Error: Access Denied`

**Solutions:**
- Check Azure RBAC assignments
- Ensure user has `Contributor` role
- Verify subscription permissions

### GCP Authentication Problems

**Error:** `Error: Failed to get existing workspaces`

**Solutions:**
```bash
# Check GCP authentication
gcloud auth list

# If not authenticated:
gcloud auth login

# Set project:
gcloud config set project YOUR_PROJECT_ID
```

**Error:** `Error: Access Denied`

**Solutions:**
- Check GCP IAM roles
- Ensure service account has required permissions:
  - `Compute Admin`
  - `Storage Admin`
  - `SQL Admin`
  - `Service Account User`

## 🏗️ Terraform Issues

### State File Problems

**Error:** `Error: state file is locked`

**Solutions:**
```bash
# Check for locks
terraform force-unlock LOCK_ID

# Or wait for lock to expire (usually 10 minutes)
```

**Error:** `Error: Backend configuration changed`

**Solutions:**
```bash
# Reinitialize with new backend
terraform init -reconfigure

# Or migrate state
terraform init -migrate-state
```

### Resource Conflicts

**Error:** `Error: resource already exists`

**Solutions:**
```bash
# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Or destroy and recreate
terraform destroy
terraform apply
```

**Error:** `Error: resource name already taken`

**Solutions:**
- Change resource names in configuration
- Use random suffixes
- Check for existing resources in console

### Provider Issues

**Error:** `Error: provider not found`

**Solutions:**
```bash
# Initialize providers
terraform init

# Update provider versions
terraform init -upgrade

# Check provider configuration
terraform providers
```

## ☁️ Cloud Provider Issues

### AWS Issues

**Error:** `Error: VPC not found`

**Solutions:**
- Check region configuration
- Verify VPC exists in correct region
- Check AWS CLI region setting

**Error:** `Error: Insufficient capacity`

**Solutions:**
- Try different availability zones
- Use different instance types
- Check AWS service limits

### Azure Issues

**Error:** `Error: Resource group not found`

**Solutions:**
- Check resource group name
- Verify subscription
- Check Azure CLI configuration

**Error:** `Error: Location not available`

**Solutions:**
- Try different Azure regions
- Check service availability
- Verify subscription permissions

### GCP Issues

**Error:** `Error: Project not found`

**Solutions:**
- Check project ID
- Verify project exists
- Check billing status

**Error:** `Error: API not enabled`

**Solutions:**
```bash
# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

## 🔧 Configuration Issues

### Variable Problems

**Error:** `Error: required variable not set`

**Solutions:**
- Check `terraform.tfvars` file
- Set environment variables
- Verify variable names

**Error:** `Error: invalid variable value`

**Solutions:**
- Check variable types
- Verify allowed values
- Review validation rules

### Backend Issues

**Error:** `Error: backend configuration invalid`

**Solutions:**
- Check backend configuration
- Verify credentials
- Test backend access

**Error:** `Error: state file not found`

**Solutions:**
- Check backend configuration
- Verify state file path
- Initialize backend

## 🚀 Deployment Issues

### Plan Failures

**Error:** `Error: plan failed`

**Solutions:**
```bash
# Check configuration
terraform validate

# Review plan output
terraform plan -detailed-exitcode

# Check for syntax errors
terraform fmt -check
```

### Apply Failures

**Error:** `Error: apply failed`

**Solutions:**
- Check resource dependencies
- Verify permissions
- Review error messages
- Check cloud provider limits

**Error:** `Error: timeout waiting for resource`

**Solutions:**
- Increase timeout values
- Check resource status
- Verify network connectivity

## 🔍 Debugging Tips

### Enable Debug Logging

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run Terraform commands
terraform plan
terraform apply
```

### Check Resource Status

```bash
# AWS
aws ec2 describe-instances
aws rds describe-db-instances

# Azure
az vm list
az mysql server list

# GCP
gcloud compute instances list
gcloud sql instances list
```

### Review Logs

```bash
# Check Terraform logs
cat terraform.log

# Check cloud provider logs
# AWS: CloudWatch Logs
# Azure: Azure Monitor
# GCP: Cloud Logging
```

## 🆘 Getting Help

### Self-Service Resources

1. **Terraform Documentation**: [https://www.terraform.io/docs](https://www.terraform.io/docs)
2. **Cloud Provider Documentation**:
   - [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
   - [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
   - [GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Community Support

1. **Terraform Community**: [https://discuss.hashicorp.com/c/terraform-core](https://discuss.hashicorp.com/c/terraform-core)
2. **Stack Overflow**: Tag questions with `terraform`, `aws`, `azure`, `gcp`
3. **GitHub Issues**: Create an issue in the repository

### Professional Support

1. **HashiCorp Support**: [https://www.hashicorp.com/support](https://www.hashicorp.com/support)
2. **Cloud Provider Support**:
   - AWS Support
   - Azure Support
   - Google Cloud Support

## 📋 Checklist for Common Issues

### Before Deployment
- [ ] Verify cloud provider credentials
- [ ] Check required permissions
- [ ] Validate Terraform configuration
- [ ] Review resource limits
- [ ] Test network connectivity

### During Deployment
- [ ] Monitor deployment progress
- [ ] Check for error messages
- [ ] Verify resource creation
- [ ] Test connectivity
- [ ] Validate configuration

### After Deployment
- [ ] Verify all resources created
- [ ] Test application functionality
- [ ] Check monitoring and logging
- [ ] Validate security settings
- [ ] Review cost implications

## 🎯 Prevention Tips

### Best Practices
1. **Use version control** for all configurations
2. **Test in development** before production
3. **Use remote state** for team collaboration
4. **Implement proper tagging** for cost management
5. **Set up monitoring** and alerting
6. **Regular backups** of state files
7. **Document changes** and configurations

### Common Mistakes to Avoid
1. **Hardcoded credentials** in configuration
2. **Missing resource dependencies**
3. **Incorrect variable types**
4. **Missing required permissions**
5. **Ignoring resource limits**
6. **Not testing configurations**
7. **Skipping validation steps**

---

**Still having issues?** Create a detailed issue in the repository with:
- Error messages
- Configuration files
- Steps to reproduce
- Environment details
- Log files (if applicable)
