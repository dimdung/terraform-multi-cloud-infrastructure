#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y apache2 mysql-client curl wget

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

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
    <p>Database Host: ${db_host}</p>
    <p>Database Name: ${db_name}</p>
    <p>Instance ID: $(curl -s http://metadata.google.internal/computeMetadata/v1/instance/id -H "Metadata-Flavor: Google")</p>
    <p>Zone: $(curl -s http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")</p>
</body>
</html>
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart apache2
