terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
    
}

variable "server_port"{
    description = "Server port for HTTP request "
    type = number
    default = 22

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-size"
    values = ["8"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
default = true
}

resource "aws_security_group" "instance"{
    name = "fox"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

}
resource "aws_instance" "web_server"{
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    # user_data = file("init.sh")
    # user_data_replace_on_change = true
    tags = {
        Name = "mox"
    }

}

resource "aws_launch_configuration" "web_server" {
image_id        = data.aws_ami.ubuntu.id
instance_type = "t2.micro"
security_groups = [aws_security_group.instance.id]

lifecycle {
create_before_destroy = true
}
}

data "aws_subnets" "default" {
filter {
name = "vpc-id"
values = [data.aws_vpc.default.id]
}
}

resource "aws_autoscaling_group" "web_server" {
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.t-group.arn]
  health_check_type = "ELB"
  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "pox"
    propagate_at_launch = true
  }
}

resource "aws_lb" "myloadbal" {
  name = "hox"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups =[aws_security_group.instance.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.myloadbal.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }

}

resource "aws_lb_target_group" "t-group" {
  name = "target-group"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher ="200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.t-group.arn
  }
}

# output "public_ip" {
#     value = aws_instance.web_server.public_ip
#     description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value = aws_lb.myloadbal.dns_name
  description = "The domain name of my load balancer"
}
