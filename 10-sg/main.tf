module "frontend"{
    # source          = "../../terraform-aws-security-group-module"
    source          = "git::https://github.com/gsurendhar/terraform-aws-security-group-module.git?ref=master"
    project         = var.project
    environment     = var.environment
    sg_name         = var.sg_name
    sg_description  = var.sg_description
    # vpc_id          = data.aws_ssm_parameter.vpc_id.value
    vpc_id          = local.vpc_id
}

