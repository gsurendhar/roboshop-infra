module "frontend" {
  # source          = "../../terraform-aws-security-group-module"
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "${local.Name}-${var.sg_name}"
  sg_description = var.sg_description
  # vpc_id          = data.aws_ssm_parameter.vpc_id.value
  vpc_id = local.vpc_id
}

#  creating SG for bastion host to connection from laptops
module "bastion" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "${local.Name}-bastion"
  sg_description = "created sg for bastion instances"
  vpc_id         = local.vpc_id
}

#  creating SG for backend-alb to connection from bastion and vpn
module "backend_alb" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "${local.Name}-backend_alb"
  sg_description = "created sg for backend load balancer"
  vpc_id         = local.vpc_id
}

#  creating SG for VPN to connection from laptop
module "vpn" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "${local.Name}-vpn"
  sg_description = "created sg for vpn"
  vpc_id         = local.vpc_id
}

#  creating SG for mongodb to connection from bastion and vpn
module "mongodb" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "mongodb"
  sg_description = "created sg for mongodb"
  vpc_id         = local.vpc_id
}

#  creating SG for redis to connection from bastion and vpn
module "redis" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "redis"
  sg_description = "created sg for redis"
  vpc_id         = local.vpc_id
}

#  creating SG for mysql to connection from bastion and vpn
module "mysql" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "mysql"
  sg_description = "created sg for mysql"
  vpc_id         = local.vpc_id
}

#  creating SG for rabbitmq to connection from bastion and vpn
module "rabbitmq" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "rabbitmq"
  sg_description = "created sg for rabbitmq"
  vpc_id         = local.vpc_id
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
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #   cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend_alb.sg_id
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

# mongodb connection to open 22, 27017 ports 
resource "aws_security_group_rule" "mongodb_ssh_vpn" {
  count     = length(var.mongodb_ports_vpn)
  type      = "ingress"
  from_port = var.mongodb_ports_vpn[count.index]
  to_port   = var.mongodb_ports_vpn[count.index]
  protocol  = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mongodb.sg_id
}

# redis connection to open 22, 6379 ports 
resource "aws_security_group_rule" "redis_ssh_vpn" {
  count     = length(var.redis_ports_vpn)
  type      = "ingress"
  from_port = var.redis_ports_vpn[count.index]
  to_port   = var.redis_ports_vpn[count.index]
  protocol  = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.redis.sg_id
}

# mysql connection to open 22, 3306 ports 
resource "aws_security_group_rule" "mysql_ssh_vpn" {
  count     = length(var.mysql_ports_vpn)
  type      = "ingress"
  from_port = var.mysql_ports_vpn[count.index]
  to_port   = var.mysql_ports_vpn[count.index]
  protocol  = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mysql.sg_id
}

# rabbitmq connection to open 22, 5672 ports 
resource "aws_security_group_rule" "rabbitmq_ssh_vpn" {
  count     = length(var.rabbitmq_ports_vpn)
  type      = "ingress"
  from_port = var.rabbitmq_ports_vpn[count.index]
  to_port   = var.rabbitmq_ports_vpn[count.index]
  protocol  = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.rabbitmq.sg_id
}
