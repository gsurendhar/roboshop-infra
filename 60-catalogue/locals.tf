locals {
  ami_id             = data.aws_ami.devops.id
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  mongodb_sg_id      = data.aws_ssm_parameter.mongodb_sg_id.value
  redis_sg_id        = data.aws_ssm_parameter.redis_sg_id.value
  mysql_sg_id        = data.aws_ssm_parameter.mysql_sg_id.value
  rabbitmq_sg_id     = data.aws_ssm_parameter.rabbitmq_sg_id.value
  catalogue_sg_id    = data.aws_ssm_parameter.catalogue_sg_id.value

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }

  Name = "${var.project}-${var.environment}"

  zone_name = data.aws_route53_zone.selected.name
  zone_id = data.aws_route53_zone.selected.zone_id

}