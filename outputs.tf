output "public_ip" {
    value = aws_instance.web_server.public_ip
    description = "The public IP address of the web server"
}

output "alb_dns_name" {
  value = aws_lb.myloadbal.dns_name
  description = "The domain name of my load balancer"
}
