terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider: Region 1 – Mumbai
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

# Provider: Region 2 – Singapore
provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

# Get latest Amazon Linux 2 AMI via SSM (Mumbai)
data "aws_ssm_parameter" "al2_mumbai" {
  provider = aws.mumbai
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Get latest Amazon Linux 2 AMI via SSM (Singapore)
data "aws_ssm_parameter" "al2_singapore" {
  provider = aws.singapore
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 in Mumbai (t3.micro)
resource "aws_instance" "mumbai_ec2" {
  provider      = aws.mumbai
  ami           = data.aws_ssm_parameter.al2_mumbai.value
  instance_type = "t3.micro"

  tags = {
    Name = "Mumbai-Terraform-EC2"
  }
}

# EC2 in Singapore (t3.micro)
resource "aws_instance" "singapore_ec2" {
  provider      = aws.singapore
  ami           = data.aws_ssm_parameter.al2_singapore.value
  instance_type = "t3.micro"

  tags = {
    Name = "Singapore-Terraform-EC2"
  }
}
