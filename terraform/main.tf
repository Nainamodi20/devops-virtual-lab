terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Security group for our DevOps server
resource "aws_security_group" "devops_sg" {
  name        = "devops-lab-sg"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes NodePort"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-lab-sg"
  }
}

# Kubernetes server
resource "aws_instance" "devops_server" {
  ami           = "ami-0fef201115eefe936"
  instance_type = "t3.small"
  key_name      = "key-pair"

  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  tags = {
    Name = "DevOps-Kubernetes-Server"
  }
}

output "public_ip" {
  description = "Public IP address of the DevOps server"
  value       = aws_instance.devops_server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.devops_server.id
}