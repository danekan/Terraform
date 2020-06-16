variable "whitelist" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "web_image_id" {
    type    = string
}
variable "web_instance_type" {
    type    = string
}
variable "web_desired_capacity" {
    type    = number
}
variable "web_max_size" {
    type    = number
}
variable "web_min_size" {
    type    = number
}
variable "environment" {
    type    = string
}
variable "appname" {
    type    = string
}
#variable "subnets" {
#    type = list(string)
#}
#variable "security_groups" {
#    type = list(string)
#}

provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

resource "aws_s3_bucket" "prod_tf_created" {
    bucket = "danekantner-tf-2020"
    acl    = "private"
}

# USE THE DEFAULT VPC

resource "aws_default_vpc" "default" {
}

# SET UP DEFAULT SUBNETS 1 PER AZ IN USE

resource "aws_default_subnet" "default_az1" {
    availability_zone = "us-east-1a"
    
    tags = {
        "Terraform"   = "true"
        "Environment" = var.environment
    }
}


resource "aws_default_subnet" "default_az2" {
    availability_zone = "us-east-1b"
    
    tags = {
        "Terraform"   = "true"
        "Environment" = var.environment
    }
}

resource "aws_security_group" "prod_tf_web" {
    name        = "prod_tf_web"
    description = "Allow standard http and https ports inbound and everything outbound"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.whitelist
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.whitelist
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"   
        cidr_blocks = var.whitelist
    }

    tags = {
        "Terraform"   = "true"
        "Environment" = var.environment
    }
}


module "web_server1" {
  #var.variables refer to root variables from this root (terraform.tfvars)
  source                 = "./modules/autoscaleEC2"
  web_image_id           = var.web_image_id
  web_instance_type      = var.web_instance_type
  web_desired_capacity   = var.web_desired_capacity
  web_max_size           = var.web_max_size
  web_min_size           = var.web_min_size   
  subnets                = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups        = [aws_security_group.prod_tf_web.id]
  appname                = var.appname
  environment            = var.environment
}
