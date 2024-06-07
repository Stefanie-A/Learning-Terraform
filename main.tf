provider "aws"{
    region = "us-east-1"
    
}
resource "aws_security_group" "instance"{
    name = "fox"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "web_server"{
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    tags = {
        Name = "fox"
    }
    user_data = file(init.sh)
    user_data_replace_on_change = true

}
