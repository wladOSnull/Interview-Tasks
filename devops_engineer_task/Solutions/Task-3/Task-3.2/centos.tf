provider "aws" {
   region                  = "eu-central-1"
   shared_credentials_file = "/home/wlados/.aws/credentials"   
}

variable "private_key" {
  default = "aws_key"
}

resource "aws_instance" "SH" {
    ami                    = "ami-08b6d44b4f6f7b279"
    instance_type          = "t2.micro"
    key_name               = "aws_key"
    vpc_security_group_ids = [aws_security_group.main.id]

    tags = {
      Name = "Terraform-AWX"
    }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {  
      cidr_blocks      = ["0.0.0.0/0",]
      description      = "for Nginx"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },  
    {  
      cidr_blocks      = ["0.0.0.0/0",]
      description      = "for me"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = file("./aws_key.pub")
}
