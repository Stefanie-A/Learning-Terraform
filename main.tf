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

resource "aws_security_group" "instance"{
    name = "fox"
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "web_server"{
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    tags = {
        Name = "mox"
    }

}

data "aws_vpc" "default" {
default = true
}

resource "aws_launch_configuration" "web_server" {
image_id = "ami-03b425a3efaaad179"
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
value = "terraform-asg-example"
propagate_at_launch = true
}
}

output "public_ip" {
    value = aws_instance.web_server.public_ip
    description = "The public IP address of the web server"
}
