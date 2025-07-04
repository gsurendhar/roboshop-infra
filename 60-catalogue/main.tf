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
