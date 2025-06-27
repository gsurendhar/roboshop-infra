data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "backend_alb_sg_id"{
  name = "/${var.project}/${var.environment}/backend_alb_sg_id"
}