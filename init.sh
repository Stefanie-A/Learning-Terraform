#!/bin/bash
echo "Welcome!" > index.html
nohup busybox httpd -f -p ${var.server_port} &
sudo apt update
sudo apt upgrade
