# Backend_ALB Target_group of Catalogue
resource "aws_lb_target_group" "catalogue" {
  name     = "${local.Name}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200-299"
    path                = "/health"
    port                = "8080"
    timeout             = 2
    unhealthy_threshold = 3
  }
}

# catalogue instance creation
resource "aws_instance" "catalogue" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  subnet_id              = local.private_subnet_id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.Name}-catalogue"
    }
  )
}

# catalogue configuration using ansible-pull 
resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.catalogue.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue"
    ]
  }
}

# Stop the instance for taking ami after provisioning
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue]
}

# taking AMI of Stopped Catalogue instance
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.Name}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue]
}

# terminating the catalogue instance after taking AMI
resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  # to execute aws command you must have aws configure in your laptop
  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id} "
  }
  depends_on = [aws_ami_from_instance.catalogue]
}


# creating catalogue launch template for ASG
resource "aws_launch_template" "catalogue" {
  name = "${local.Name}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  update_default_version = true

  # instance tags
  tag_specifications {
    resource_type = "instance"

    tags = merge (
      local.common_tags,
      {
      Name = "${local.Name}-catalogue"
      }
    )
  }

  # volume tags
  tag_specifications {
    resource_type = "volume"

    tags = merge (
      local.common_tags,
      {
      Name = "${local.Name}-catalogue"
      }
    )
  }

  # launch template tags
  tags = merge (
    local.common_tags,
    {
    Name = "${local.Name}-catalogue"
    }
  )
}

# catalogue ASG




resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.Name}-catalogue"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 90
  health_check_type         = "ELB"
  vpc_zone_identifier       = local.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.catalogue.arn]
 
 
  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }
  

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name  = "${local.Name}-catalogue"
      }
    )

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  timeouts {
    delete = "15m"
  }

}

# ASG Policy
resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${local.Name}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

# ALB Listener Rule
resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-${var.environment}.gonela.site"]
    }
  }
}