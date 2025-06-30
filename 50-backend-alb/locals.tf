locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids  = split("," , data.aws_ssm_parameter.private_subnet_ids.value)
  backend_alb_sg_id  = data.aws_ssm_parameter.backend_alb_sg_id.value

  common_tags = {
      Project      = var.project
      Environment  = var.environment
      Terraform    = true
  }

  Name = "${var.project}-${var.environment}"

  zone_name = data.aws_route53_zone.selected.name
  zone_id = data.aws_route53_zone.selected.zone_id
}