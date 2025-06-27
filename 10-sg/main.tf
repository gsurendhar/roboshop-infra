module "frontend"{
    # source          = "../../terraform-aws-security-group-module"
    source          = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
    project         = var.project
    environment     = var.environment
    sg_name         = "${local.Name}-${var.sg_name}"
    sg_description  = var.sg_description
    # vpc_id          = data.aws_ssm_parameter.vpc_id.value
    vpc_id          = local.vpc_id
}

#  creating SG for bastion host to connection from laptops
module "bastion"{
    source          = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
    project         = var.project
    environment     = var.environment
    sg_name         = "${local.Name}-bastion"
    sg_description  = "created sg for bastion instances"
    vpc_id          = local.vpc_id
}

module "backend_alb"{
    source          = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
    project         = var.project
    environment     = var.environment
    sg_name         = "${local.Name}-backend_alb"
    sg_description  = "created sg for backend load balancer"
    vpc_id          = local.vpc_id
}

module "vpn"{
    source          = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
    project         = var.project
    environment     = var.environment
    sg_name         = "${local.Name}-vpn"
    sg_description  = "created sg for vpn"
    vpc_id          = local.vpc_id
}









# bastion accepting connections from my laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# ALB accepting connections from bastion host on port no 80
resource "aws_security_group_rule" "backend_alb_bastion" {
  type                      = "ingress"
  from_port                 = 80
  to_port                   = 80
  protocol                  = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id  = module.bastion.sg_id
  security_group_id         = module.backend_alb.sg_id
}

# vpn connection to open 22,443,943,1194 ports 
resource "aws_security_group_rule" "vpn_ports" {
  count             = length(var.vpn_ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}