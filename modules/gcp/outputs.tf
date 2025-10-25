# GCP Module Outputs

# Project Outputs
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

# VPC Network Outputs
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = google_compute_subnetwork.public[*].name
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = google_compute_subnetwork.private[*].name
}

# Cloud Storage Outputs
output "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.main.name
}

output "storage_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.main.url
}

# Cloud SQL Outputs
output "sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "sql_instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "sql_instance_private_ip" {
  description = "Private IP of the Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "sql_database_name" {
  description = "Name of the Cloud SQL database"
  value       = google_sql_database.main.name
}

# Compute Engine Outputs
output "instance_template_name" {
  description = "Name of the instance template"
  value       = google_compute_instance_template.main.name
}

output "managed_instance_group_name" {
  description = "Name of the managed instance group"
  value       = google_compute_instance_group_manager.main.name
}

# Load Balancer Outputs
output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_global_address.main.address
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = google_compute_global_forwarding_rule.main.name
}

output "backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.main.name
}

# Health Check Outputs
output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.main.name
}

# Firewall Outputs
output "web_firewall_name" {
  description = "Name of the web firewall rule"
  value       = google_compute_firewall.web.name
}

output "ssh_firewall_name" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.ssh.name
}

output "database_firewall_name" {
  description = "Name of the database firewall rule"
  value       = google_compute_firewall.database.name
}

# Logging Outputs
output "log_sink_name" {
  description = "Name of the log sink"
  value       = google_logging_project_sink.main.name
}

# Service Networking Outputs
output "private_ip_address_name" {
  description = "Name of the private IP address"
  value       = google_compute_global_address.private_ip_address.name
}

output "private_vpc_connection_name" {
  description = "Name of the private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection.network
}
