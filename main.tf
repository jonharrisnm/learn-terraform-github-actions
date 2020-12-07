terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    organization = "jharris-demo"

    workspaces {
      name = "github-actions-demo"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

### Defining if the default VPC will be used

data "aws_vpc" "default" {
  default = true
}

### Defining what subnet ids will be used

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

### Defining resource for EC2 instances and configuration

resource "aws_instance" "web" {
    ami                    = "ami-0a07be880014c7b8e"
    count                  = var.instance_count
    instance_type          = var.instance_type
    key_name               = "jharris"
    vpc_security_group_ids = [aws_security_group.http-nginx.id]
    user_data              = <<-EOF
                           #!/bin/bash
                           sudo yum update -y
                           sudo yum install nginx -y
                           sudo service nginx start
                           sudo chkconfig nginx on
                           EOF

    tags              = {
        Name      = "${var.instance_name}-${count.index + 1}"
        owner     = var.owner
        se-region = var.se-region
        purpose   = var.purpose
        ttl       = var.ttl
        terraform = var.terraform
    }
}

### Defining resource for Load Balancer and configuration

resource "aws_alb" "https-lb" {
    name                       = var.alb_name
    internal                   = false
    load_balancer_type         = "application"
    enable_deletion_protection = false
    security_groups            = [aws_security_group.http-nginx.id]
    subnets                    = data.aws_subnet_ids.all.ids
    
    tags = {
        Environment = var.instance_name
        owner     = var.owner
        se-region = var.se-region
        purpose   = var.purpose
        ttl       = var.ttl
        terraform = var.terraform
    }

}

###  Defining resource for Load Balancer Target Group and configuration

resource "aws_lb_target_group" "app_instances" {
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id

  tags = {
        owner     = var.owner
        se-region = var.se-region
        purpose   = var.purpose
        ttl       = var.ttl
        terraform = var.terraform

  }

}

### Defining resource for Load Balancer Listener and configuration

resource "aws_lb_listener" "https-lb"  {
  load_balancer_arn = aws_alb.https-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_instances.arn
  }
}

### Defining resource for registering instances with Load Balancer Target Group.
### Note since count was used to generate instances needed a way to feed in instance
### ids individually.  Found that a combination of count.index 
### and count with length function I could achieve this. 

resource "aws_lb_target_group_attachment" "app-group" {
  target_group_arn = aws_lb_target_group.app_instances.arn
  target_id        = aws_instance.web[count.index].id
  port             = "80"
  count            = length(aws_instance.web)
}

### Defining resource for new secruity group for Load Balancer and intances to use

resource "aws_security_group" "http-nginx" {
  description = " Allow HTTP to Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  tags         ={

        owner     = var.owner
        se-region = var.se-region
        purpose   = var.purpose
        ttl       = var.ttl
        terraform = var.terraform
  }

### Defining rule of inbound traffic
ingress {
  description = " HTTTP from outside"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

### Defining rule for outbound traffic

egress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

}
