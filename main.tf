terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "jewelry-app-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "jewelry-app-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "jewelry-app-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "jewelry-app-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "main" {
  name        = "jewelry-app-sg"
  description = "Security group for jewelry app"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = {
    Name = "jewelry-app-sg"
  }
}

# Key Pair for EC2 instance
resource "aws_key_pair" "main" {
  key_name   = "jewelry-app-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    docker container stop jewelry-app 2> /dev/null

    cd /home/ec2-user
    rm -rf proway-docker/
    git clone https://github.com/dartanghan/proway-docker.git
    cd proway-docker/modulo7-iac_tooling
    
    docker build -t jewelry-app .
    docker run -d -p 8080:80 jewelry-app
  EOF
  )
  
  tags = {
    Name = "jewelry-app-ec2"
  }
}

output "vm_public_ip" {
  value = aws_instance.main.public_ip
}

output "app_url" {
  value = "http://${aws_instance.main.public_ip}:8080"
}
