# Find two available Availability Zones

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}

# Two public subnets in different Availability Zones

resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = (
    count.index == 0
    ? "11.0.1.0/24"
    : "11.0.2.0/24"
  )

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-public-subnet-${count.index + 1}"
  }
}

# Public route table with internet access

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

# Associate both subnets with the public route table

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group

resource "aws_security_group" "web" {
  name        = "devops-web-sg"
  description = "SSH from my IP and HTTP website access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP website"
    from_port   = 80
    to_port     = 80
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
    Name = "devops-web-sg"
  }
}

# Two EC2 instances, one in each subnet

resource "aws_instance" "web" {
  count = 2

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  # Install Docker automatically when the instance boots

  user_data = <<-EOF
#!/bin/bash
set -eux
apt-get update -y
apt-get install -y docker.io
systemctl enable --now docker
EOF

  tags = {
    Name = "devops-web-${count.index + 1}"
  }

  depends_on = [
    aws_route_table_association.public
  ]
}
