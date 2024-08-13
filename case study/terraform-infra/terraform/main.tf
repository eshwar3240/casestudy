terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  # Adjust the version as needed
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for all subnets in the default VPC
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source for the Internet Gateway associated with the default VPC
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data source for the route table associated with the default VPC
data "aws_route_table" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Retrieve public subnets by filtering subnets that have a route to the Internet Gateway
locals {
  public_subnet_ids = [
    for subnet_id in data.aws_subnets.all.ids : subnet_id
    if contains(data.aws_route_table.default.routes[*].gateway_id, data.aws_internet_gateway.default.id)
  ]
}

# Data source for default security group
data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]  # Change this to the exact name of your security group
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ALB
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Owner       = "DevOps Team"
    Project     = "Terraform Demo"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello, World!"
      status_code  = "200"
    }
  }
}


output "elb_dns_name" {
  value = aws_lb.test.dns_name
}