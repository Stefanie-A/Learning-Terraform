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
        from_port = var.server_port
        to_port = var.server_port
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
    user_data = file("init.sh")
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
  security_groups =[aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.myloadbal.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-respomse"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }

}
resource "aws_lb_target_group" "name" {
  name = "target-group"
  port = ""
}

output "public_ip" {
    value = aws_instance.web_server.public_ip
    description = "The public IP address of the web server"
}
