terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------- PROVIDERS (2 REGIONS) --------

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

# -------- GET LATEST AMAZON LINUX 2 AMI --------

data "aws_ssm_parameter" "al2_mumbai" {
  provider = aws.mumbai
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "al2_singapore" {
  provider = aws.singapore
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# -------- SECURITY GROUP (ALLOW HTTP) --------

resource "aws_security_group" "web_sg_mumbai" {
  provider = aws.mumbai
  name     = "nginx-sg-mumbai"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg_singapore" {
  provider = aws.singapore
  name     = "nginx-sg-singapore"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------- USER DATA SCRIPT TO INSTALL NGINX --------

locals {
  user_data_script = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Deployed via Terraform in $(hostname -f)</h1>" > /usr/share/nginx/html/index.html
              EOF
}

# -------- EC2 MUMBAI --------

resource "aws_instance" "mumbai_ec2" {
  provider               = aws.mumbai
  ami                    = data.aws_ssm_parameter.al2_mumbai.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg_mumbai.id]
  user_data              = local.user_data_script

  tags = {
    Name = "Mumbai-Nginx-Server"
  }
}

# -------- EC2 SINGAPORE --------

resource "aws_instance" "singapore_ec2" {
  provider               = aws.singapore
  ami                    = data.aws_ssm_parameter.al2_singapore.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg_singapore.id]
  user_data              = local.user_data_script

  tags = {
    Name = "Singapore-Nginx-Server"
  }
}

# -------- OUTPUT PUBLIC IPS --------

output "mumbai_public_ip" {
  value = aws_instance.mumbai_ec2.public_ip
}

output "singapore_public_ip" {
  value = aws_instance.singapore_ec2.public_ip
}
