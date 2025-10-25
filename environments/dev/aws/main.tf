# AWS Development Environment
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Use the AWS module
module "aws_infrastructure" {
  source = "../../../modules/aws"

  # Project Configuration
  project_name = var.project_name
  environment  = var.environment

  # AWS Configuration
  aws_region = var.aws_region

  # Networking
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones    = var.availability_zones

  # Compute
  instance_type    = var.instance_type
  ami_id          = var.ami_id
  min_size        = var.min_size
  max_size        = var.max_size
  desired_capacity = var.desired_capacity

  # Database
  db_instance_class           = var.db_instance_class
  db_allocated_storage        = var.db_allocated_storage
  db_max_allocated_storage    = var.db_max_allocated_storage
  db_name                     = var.db_name
  db_username                 = var.db_username
  db_password                 = var.db_password
  db_backup_retention_period  = var.db_backup_retention_period

  # Logging
  log_retention_days = var.log_retention_days

  # Tags
  tags = var.tags
}
