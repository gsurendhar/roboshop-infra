#  creating SG for bastion host to connection from laptops
module "bastion" {
  # source          = "../../terraform-aws-security-group-module"
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "bastion"
  sg_description = "created sg for bastion instances"
  # vpc_id          = data.aws_ssm_parameter.vpc_id.value
  vpc_id         = local.vpc_id
}

#  creating SG for VPN to connection from laptop
module "vpn" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "vpn"
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

#  creating SG for catalogue to connection from bastion and vpn
module "catalogue" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "catalogue"
  sg_description = "created sg for catalogue"
  vpc_id         = local.vpc_id
}

#  creating SG for USER to connection from bastion and vpn
module "user" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "user"
  sg_description = "created sg for user"
  vpc_id         = local.vpc_id
}

#  creating SG for CART to connection from bastion and vpn
module "cart" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "cart"
  sg_description = "created sg for cart"
  vpc_id         = local.vpc_id
}

#  creating SG for SHIPPING to connection from bastion and vpn
module "shipping" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "shipping"
  sg_description = "created sg for shipping"
  vpc_id         = local.vpc_id
}

#  creating SG for PAYMENT to connection from bastion and vpn
module "payment" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "payment"
  sg_description = "created sg for payment"
  vpc_id         = local.vpc_id
}

#  creating SG for backend-alb to connection from bastion and vpn
module "backend_alb" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "backend_alb"
  sg_description = "created sg for backend load balancer"
  vpc_id         = local.vpc_id
}

module "frontend" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = var.sg_name
  sg_description = var.sg_description
  vpc_id = local.vpc_id
}

#  creating SG for frontend-alb to connection from bastion and vpn
module "frontend_alb" {
  source         = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
  project        = var.project
  environment    = var.environment
  sg_name        = "frontend_alb"
  sg_description = "created sg for frontend load balancer"
  vpc_id         = local.vpc_id
}






# BASTION accepting connections from my laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# BACKEND ALB accepting connections from bastion host on port no 80
resource "aws_security_group_rule" "backend_alb_bastion" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #   cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend_alb.sg_id
}

# VPN connection to open 22,443,943,1194 ports 
resource "aws_security_group_rule" "vpn_ports" {
  count             = length(var.vpn_ports)
  type              = "ingress"
  from_port         = var.vpn_ports[count.index]
  to_port           = var.vpn_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}




# MONGODB accepting connections from openvpn 22, 27017 ports 
resource "aws_security_group_rule" "mongodb_ssh_vpn" {
  count     = length(var.mongodb_ports)
  type      = "ingress"
  from_port = var.mongodb_ports[count.index]
  to_port   = var.mongodb_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mongodb.sg_id
}

# MONGODB accepting connections from bastion 22, 27017 ports 
resource "aws_security_group_rule" "mongodb_ssh_bastion" {
  count     = length(var.mongodb_ports)
  type      = "ingress"
  from_port = var.mongodb_ports[count.index]
  to_port   = var.mongodb_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.mongodb.sg_id
}


# MONGODB accepting connections from catalogue 27017  port 
resource "aws_security_group_rule" "mongodb_catalogue" {
  type      = "ingress"
  from_port = 27017
  to_port   = 27017
  protocol  = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id        = module.mongodb.sg_id
}

# MONGODB accepting connections from user 27017  port 
resource "aws_security_group_rule" "mongodb_user" {
  type      = "ingress"
  from_port = 27017
  to_port   = 27017
  protocol  = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.mongodb.sg_id
}

# REDIS accepting connections from openvpn 22, 6379 ports 
resource "aws_security_group_rule" "redis_ssh_vpn" {
  count     = length(var.redis_ports)
  type      = "ingress"
  from_port = var.redis_ports[count.index]
  to_port   = var.redis_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.redis.sg_id
}

# REDIS accepting connections from bastion 22, 6379 ports 
resource "aws_security_group_rule" "redis_ssh_bastion" {
  count     = length(var.redis_ports)
  type      = "ingress"
  from_port = var.redis_ports[count.index]
  to_port   = var.redis_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.redis.sg_id
}

# REDIS accepting connections from user 6379 port 
resource "aws_security_group_rule" "redis_user" {
  type      = "ingress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id        = module.redis.sg_id
}

# REDIS accepting connections from cart 6379 port
resource "aws_security_group_rule" "redis_cart" {
  type      = "ingress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.redis.sg_id
}

# MYSQL accepting connections from openvpn 22, 3306 ports 
resource "aws_security_group_rule" "mysql_ssh_vpn" {
  count     = length(var.mysql_ports)
  type      = "ingress"
  from_port = var.mysql_ports[count.index]
  to_port   = var.mysql_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.mysql.sg_id
}

# MYSQL accepting connections from bastion 22, 3306 ports 
resource "aws_security_group_rule" "mysql_ssh_bastion" {
  count     = length(var.mysql_ports)
  type      = "ingress"
  from_port = var.mysql_ports[count.index]
  to_port   = var.mysql_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.mysql.sg_id
}

# MYSQL accepting connections from shipping 3306 port
resource "aws_security_group_rule" "mysql_shipping" {
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.mysql.sg_id
}

# RABBITMQ accepting connections from openvpn 22, 5672 ports 
resource "aws_security_group_rule" "rabbitmq_ssh_vpn" {
  count     = length(var.rabbitmq_ports)
  type      = "ingress"
  from_port = var.rabbitmq_ports[count.index]
  to_port   = var.rabbitmq_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.rabbitmq.sg_id
}

# RABBITMQ accepting connections from bastion 22, 5672 ports 
resource "aws_security_group_rule" "rabbitmq_ssh_bastion" {
  count     = length(var.rabbitmq_ports)
  type      = "ingress"
  from_port = var.rabbitmq_ports[count.index]
  to_port   = var.rabbitmq_ports[count.index]
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.rabbitmq.sg_id
}

# RABBITMQ accepting connections from payment 5672 ports 
resource "aws_security_group_rule" "rabbitmq_payment" {
  type      = "ingress"
  from_port = 5672
  to_port   = 5672
  protocol  = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id        = module.rabbitmq.sg_id
}




# CATALOGUE accepting connections from backend_alb 8080 port 
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.catalogue.sg_id
}

# CATALOGUE accepting connections from openvpn 22  port 
resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

# CATALOGUE accepting connections from bastion 22  port 
resource "aws_security_group_rule" "catalogue_bastion_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.catalogue.sg_id
}

#  CATALOGUE accepting connections from openvpn 8080  port 
resource "aws_security_group_rule" "catalogue_vpn_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.catalogue.sg_id
}

# USER accepting connections from backend_alb 8080 port 
resource "aws_security_group_rule" "user_backend_alb" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.user.sg_id
}

# USER accepting connections from bastion 22  port 
resource "aws_security_group_rule" "user_bastion_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.user.sg_id
}

# USER accepting connections from openvpn 22  port 
resource "aws_security_group_rule" "user_vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.user.sg_id
}

#  USER accepting connections from openvpn 8080  port 
resource "aws_security_group_rule" "user_vpn_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.user.sg_id
}

# CART accepting connections from backend_alb 8080 port 
resource "aws_security_group_rule" "cart_backend_alb" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.cart.sg_id
}

# CART accepting connections from bastion 22  port 
resource "aws_security_group_rule" "cart_bastion_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.cart.sg_id
}

# CART accepting connections from openvpn 22  port 
resource "aws_security_group_rule" "cart_vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.cart.sg_id
}

#  CART accepting connections from openvpn 8080  port 
resource "aws_security_group_rule" "cart_vpn_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.cart.sg_id
}

# SHIPPING accepting connections from backend_alb 8080 port 
resource "aws_security_group_rule" "shipping_backend_alb" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.shipping.sg_id
}

# SHIPPING accepting connections from bastion 22  port 
resource "aws_security_group_rule" "shipping_bastion_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.shipping.sg_id
}

# SHIPPING accepting connections from openvpn 22  port 
resource "aws_security_group_rule" "shipping_vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.shipping.sg_id
}

#  SHIPPING accepting connections from openvpn 8080  port 
resource "aws_security_group_rule" "shipping_vpn_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.shipping.sg_id
}

# PAYMENT accepting connections from backend_alb 8080 port 
resource "aws_security_group_rule" "payment_backend_alb" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.backend_alb.sg_id
  security_group_id        = module.payment.sg_id
}

# PAYMENT accepting connections from bastion 22  port 
resource "aws_security_group_rule" "payment_bastion_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.payment.sg_id
}

# PAYMENT accepting connections from openvpn 22  port 
resource "aws_security_group_rule" "payment_vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.payment.sg_id
}

#  PAYMENT accepting connections from openvpn 8080  port 
resource "aws_security_group_rule" "payment_vpn_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.payment.sg_id
}



#  FRONTEND accepting connections from openvpn 22 port 
resource "aws_security_group_rule" "frontend_vpn_http" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.frontend.sg_id
}

#  FRONTEND accepting connections from bastion  22 port 
resource "aws_security_group_rule" "frontend_bastion_http" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.frontend.sg_id
}

#  FRONTEND accepting connections from FRONTEND_ALB 80 port 
resource "aws_security_group_rule" "frontend_frontend_alb" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id        = module.frontend.sg_id
}





#  BACKEND_ALB accepting connections from bastion 80 port 
resource "aws_security_group_rule" "backend_alb_bastion_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#  BACKEND_ALB accepting connections from openvpn 80 port 
resource "aws_security_group_rule" "backend_alb_vpn_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#  BACKEND_ALB accepting connections from frontend 80 port 
resource "aws_security_group_rule" "backend_alb_frontend" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#  BACKEND_ALB accepting connections from cart 80 port 
resource "aws_security_group_rule" "backend_alb_cart" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#  BACKEND_ALB accepting connections from shipping 80 port 
resource "aws_security_group_rule" "backend_alb_shipping" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id        = module.backend_alb.sg_id
}

#  BACKEND_ALB accepting connections from payment 80 port 
resource "aws_security_group_rule" "backend_alb_payment" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id        = module.backend_alb.sg_id
}




#  FRONTEND_ALB accepting connections from http 
resource "aws_security_group_rule" "frontend_alb_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # source_security_group_id = module.frontend_alb.sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}

#  FRONTEND_ALB accepting connections from https 
resource "aws_security_group_rule" "frontend_alb_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  # source_security_group_id = module.frontend_alb.sg_id
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}