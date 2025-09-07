module "component" {
    for_each        = var.component
    source          = "git::https://github.com/gsurendhar/terraform-aws-roboshop-dev-module.git?ref=main"
    # source          = "../../terraform-aws-roboshop-dev-module"
    component       = each.key 
    rule_priority   = each.value.rule_priority
    environment     = var.environment
}