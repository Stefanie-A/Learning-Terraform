#!/bin/bash
echo "Welcome!" > index.html
nohup busybox httpd -f -p 8080 &
sudo apt update
sudo apt upgrade
