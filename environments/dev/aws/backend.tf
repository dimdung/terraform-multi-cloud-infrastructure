# AWS Backend Configuration
terraform {
  backend "s3" {
    # Configure these values in your terraform.tfvars or as environment variables
    # bucket         = "your-terraform-state-bucket"
    # key            = "dev/aws/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "terraform-state-lock"
  }
}
