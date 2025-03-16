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

resource "aws_iam_role" "cloudwatch_role" {
    name = "cloudwatch-role-${var.environment}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })
}

resource "aws_iam_policy" "cloudwatch_policy" {
    name        = "cloudwatch-policy-${var.environment}"
    description = "Policy to allow CloudWatch logging"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect   = "Allow"
            Action   = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricData"
            ]
            Resource = "*"
        }]
    })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
    role       = aws_iam_role.cloudwatch_role.name
    policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_instance_profile" "cloudwatch_profile" {
    name = "cloudwatch-profile-${var.environment}"
    role = aws_iam_role.cloudwatch_role.name
}

resource "aws_instance" "main-vm" {
    ami                    = "ami-0d118c6e63bcb554e"
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    key_name               = var.key_name
    iam_instance_profile   = aws_iam_instance_profile.cloudwatch_profile.name

    user_data = <<-EOF
        #!/bin/bash
        yum install -y amazon-cloudwatch-agent
        cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
        {
            "agent": {
                "metrics_collection_interval": 60
            },
            "logs": {
                "logs_collected": {
                    "files": {
                        "collect_list": [
                            {
                                "file_path": "/var/log/messages",
                                "log_group_name": "/aws/ec2/${var.environment}/logs",
                                "log_stream_name": "{instance_id}"
                            }
                        ]
                    }
                }
            }
        }
        EOT
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
            -a fetch-config \
            -m ec2 \
            -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
            -s
    EOF

    tags = {
        Name = "VM-${var.environment}"
    }
}

resource "aws_cloudwatch_log_group" "instance_logs" {
    name = "/aws/ec2/${var.environment}/logs"
}

resource "aws_cloudwatch_log_stream" "instance_stream" {
    name           = "instance-log-stream"
    log_group_name = aws_cloudwatch_log_group.instance_logs.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
    alarm_name          = "HighCPUUsage-${var.environment}"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    threshold           = 80
    alarm_description   = "Alarm for high CPU usage"
    dimensions = {
        InstanceId = aws_instance.main-vm.id
    }
    alarm_actions = ["arn:aws:sns:eu-central-1:123456789012:MyTopic"]
}

resource "aws_eip" "ip" {
    instance = aws_instance.main-vm.id
    depends_on = [aws_internet_gateway.main]
}

output "instance_ip" {
    description = "Instance Public IP"
    value       = aws_instance.main-vm.public_ip
    sensitive   = false
}
