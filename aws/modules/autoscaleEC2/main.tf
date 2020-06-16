#Create classic load balancer and add all * instances of EC2
   
resource "aws_elb" "this" {
    name            = "${var.appname}-${var.environment}"
    subnets         = var.subnets
    security_groups = var.security_groups

    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
    
    tags = {
        "Terraform"   = "true"
        "Environment" = var.environment
    }
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.appname}-${var.environment}"
  image_id               = var.web_image_id
  instance_type          = var.web_instance_type
  vpc_security_group_ids = var.security_groups

  tags = {
        "Terraform" : "true"
        "Environment" : var.environment
  }
}

resource "aws_autoscaling_group" "this" {
  availability_zones  = ["us-east-1a","us-east-2b"]
  desired_capacity    = var.web_desired_capacity
  max_size            = var.web_max_size
  min_size            = var.web_min_size
  vpc_zone_identifier = var.subnets
 
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  #special tag format required for autoscaling group (other format would send tags on through to the hosts it creates)
  tag {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_attachment" "this" {
    autoscaling_group_name = aws_autoscaling_group.this.id
    elb                    = aws_elb.this.id
}