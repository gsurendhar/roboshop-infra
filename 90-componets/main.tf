module "component" {
    for_each        = var.component
    source          = "../../terraform-aws-roboshop-dev-module"
    component       = each.key 
    rule_priority   = each.value.rule_priority
}