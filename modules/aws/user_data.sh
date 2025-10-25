#!/bin/bash

# Update system
yum update -y

# Install required packages
yum install -y httpd mysql

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple index.html
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${project_name}</title>
</head>
<body>
    <h1>Welcome to ${project_name}</h1>
    <p>Environment: ${environment}</p>
    <p>Database Endpoint: ${db_endpoint}</p>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
</body>
</html>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart httpd
