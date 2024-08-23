#!/bin/bash

echo "Welcome!" > index.html
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo cp index.html /var/www/html
sudo chown -R www-data:wwww-data /var/www/html
sudo chmod -R 755 /var/www/html