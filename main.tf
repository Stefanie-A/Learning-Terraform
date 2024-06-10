terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
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

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["902839103466"] # Canonical
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
    ami = "data.aws_ami.ubuntu.id"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    tags = {
        Name = "fox"
    }

}

output "public_ip" {
    value = aws_instance.web_server.public_ip
    description = "The public IP address of the web server"
}
