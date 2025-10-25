# GCP Infrastructure Module
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"

  depends_on = [google_project_service.compute]
}

# Create Public Subnets
resource "google_compute_subnetwork" "public" {
  count = length(var.public_subnet_cidrs)

  name          = "${var.project_name}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.main.id

  depends_on = [google_project_service.compute]
}

# Create Private Subnets
resource "google_compute_subnetwork" "private" {
  count = length(var.private_subnet_cidrs)

  name          = "${var.project_name}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.main.id

  depends_on = [google_project_service.compute]
}

# Create Firewall Rule for Web Traffic
resource "google_compute_firewall" "web" {
  name    = "${var.project_name}-web-firewall"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]

  depends_on = [google_project_service.compute]
}

# Create Firewall Rule for SSH
resource "google_compute_firewall" "ssh" {
  name    = "${var.project_name}-ssh-firewall"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]

  depends_on = [google_project_service.compute]
}

# Create Firewall Rule for Database
resource "google_compute_firewall" "database" {
  name    = "${var.project_name}-db-firewall"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_tags = ["web-server"]
  target_tags = ["database"]

  depends_on = [google_project_service.compute]
}

# Create Cloud Storage Bucket
resource "google_storage_bucket" "main" {
  name          = "${var.project_name}-${random_string.suffix.result}"
  location      = var.region
  force_destroy = var.environment != "prod"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage]
}

# Create Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.project_name}-mysql-${random_string.suffix.result}"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = var.db_machine_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }

    backup_configuration {
      enabled                        = true
      start_time                    = "03:00"
      point_in_time_recovery_enabled = var.environment == "prod"
      transaction_log_retention_days = 7
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }
  }

  deletion_protection = var.environment == "prod"

  depends_on = [
    google_project_service.sql,
    google_service_networking_connection.private_vpc_connection
  ]
}

# Create Cloud SQL Database
resource "google_sql_database" "main" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name

  depends_on = [google_sql_database_instance.main]
}

# Create Cloud SQL User
resource "google_sql_user" "main" {
  name     = var.db_username
  instance = google_sql_database_instance.main.name
  password = var.db_password

  depends_on = [google_sql_database_instance.main]
}

# Create Private Service Connection
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.project_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type   = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id

  depends_on = [google_project_service.compute]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.servicenetworking]
}

# Create Instance Template
resource "google_compute_instance_template" "main" {
  name_prefix  = "${var.project_name}-template-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = var.image
    auto_delete   = true
    boot          = true
    disk_size_gb  = var.disk_size_gb
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.public[0].id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    startup-script = templatefile("${path.module}/startup-script.sh", {
      project_name = var.project_name
      environment  = var.environment
      db_host      = google_sql_database_instance.main.private_ip_address
      db_name      = var.db_name
      db_username  = var.db_username
      db_password  = var.db_password
    })
  }

  tags = ["web-server", "ssh"]

  depends_on = [google_project_service.compute]
}

# Create Managed Instance Group
resource "google_compute_instance_group_manager" "main" {
  name = "${var.project_name}-mig"

  base_instance_name = "${var.project_name}-instance"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.main.id
  }

  target_size = var.min_replicas

  auto_healing_policies {
    health_check      = google_compute_health_check.main.id
    initial_delay_sec = 300
  }

  depends_on = [google_compute_instance_template.main]
}

# Create Health Check
resource "google_compute_health_check" "main" {
  name = "${var.project_name}-health-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  depends_on = [google_project_service.compute]
}

# Create Load Balancer
resource "google_compute_backend_service" "main" {
  name        = "${var.project_name}-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group_manager.main.instance_group
  }

  health_checks = [google_compute_health_check.main.id]

  depends_on = [google_compute_instance_group_manager.main]
}

# Create URL Map
resource "google_compute_url_map" "main" {
  name            = "${var.project_name}-url-map"
  default_service = google_compute_backend_service.main.id

  depends_on = [google_compute_backend_service.main]
}

# Create HTTP Proxy
resource "google_compute_target_http_proxy" "main" {
  name    = "${var.project_name}-http-proxy"
  url_map = google_compute_url_map.main.id

  depends_on = [google_compute_url_map.main]
}

# Create Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "main" {
  name       = "${var.project_name}-forwarding-rule"
  target     = google_compute_target_http_proxy.main.id
  port_range = "80"
  ip_address = google_compute_global_address.main.address

  depends_on = [google_compute_target_http_proxy.main]
}

# Create Global Static IP
resource "google_compute_global_address" "main" {
  name = "${var.project_name}-ip"

  depends_on = [google_project_service.compute]
}

# Create Cloud Logging Log Sink
resource "google_logging_project_sink" "main" {
  name        = "${var.project_name}-log-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.main.name}"

  filter = "resource.type=\"gce_instance\""

  depends_on = [google_project_service.logging]
}

# Enable Required APIs
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
}

resource "google_project_service" "sql" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "logging" {
  service = "logging.googleapis.com"
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
