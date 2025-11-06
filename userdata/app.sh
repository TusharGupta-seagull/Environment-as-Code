#!/bin/bash

sudo yum update -y
sudo yum install -y httpd

sudo systemctl enable httpd
sudo systemctl start httpd

# Create a simple index.html for testing
echo "<html><body><h1>Welcome to the App Server!</h1><p>$(hostname)</p></body></html>" | sudo tee /var/www/html/index.html

sudo chown www-data:www-data /var/www/html/index.html

echo "Apache web server setup complete!"
