terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~>5.38"
        }
    }

    required_version = ">= 1.2.0"
    backend "s3" {
        bucket         = "kibirs-tfstate-bucket"
        key            = "terraform.tfstate"
        region         = "eu-central-1"
        encrypt        = true
        dynamodb_table = "kibirs-tfstate-lock"
    }
}

resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
}

resource "aws_subnet" "main" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.0.0/24"
    availability_zone       = "eu-central-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
    route_table_id         = aws_route_table.main.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "main" {
    subnet_id      = aws_subnet.main.id
    route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "instance_sg" {
    name        = "instance-sg-${var.environment}"
    description = "Security group for app server and backend server"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
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

resource "aws_instance" "main-vm" {
    ami                    = "ami-0d118c6e63bcb554e"
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name               = var.key_name
    tags                   = {
        Name = "VM-${var.environment}"
    }
}

resource "aws_eip" "ip" {
    instance = aws_instance.main-vm.id
    depends_on = [aws_internet_gateway.main]
}
output "instance_ip" {
    description = "Public IP of VM"
    value       = aws_instance.main-vm.public_ip
}
