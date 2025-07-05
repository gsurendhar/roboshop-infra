module "user" {
    source          = "../../terraform-aws-roboshop-dev-module"
    component       = "user" 
    rule_priority   = 20
}