variable "ssh"{
    description = "ssh port"
    type = number
    default = 22
}

variable "ami"{
    description = "ami id for ec2 instance"
    type = string
    sensitive = true
    default = "ami-0866a3c8686eaeeba"
    
    validation {
    condition     = length(var.ami) > 4 && substr(var.ami, 0, 4) == "ami-"
    error_message = "Please provide a valid value for variable AMI."
 }
}
