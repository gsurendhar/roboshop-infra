module "component" {
    for_each        = var.component
    source          = "git::https://github.com/gsurendhar/terraform-aws-roboshop-dev-module.git?ref=main"
    component       = each.key 
    rule_priority   = each.value.rule_priority
}