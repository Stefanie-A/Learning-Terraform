provider "aws"{

    region = "us-east-1b"

    tags ={
        name = "fox"
    }

    user-data = file(init.sh)
}
resources "aws_instance" "web_server"{
    ami = "ami-0fb653ca2d3203ac1"
    instance-type = "t2.micro"
}