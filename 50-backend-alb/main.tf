# open-source terraform-aws-alb-module is using
module "backend_alb" {
    source                  = "terraform-aws-module/alb/aws"
    version                 = "9.16.0"
    internal                = true 
    vpc_id                  = local.vpc_id
    subnets                 = local.private_subnet_ids
    create_security_group   = false
    security_groups         = [local.backend_alb_sg_id]

    tags = merge(
        local.common_tags,
        {
            Name = "${local.Name}-backend_alb"
        }
    )
}