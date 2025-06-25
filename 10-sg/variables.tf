variable "project" {
  default        = "roboshop"
}

variable "environment" {
  default        = "dev"
}

# variable "vpc_id" {
#   default        = string
# }

variable "sg_name" {
  default        = "frontend"
}

variable "sg_description" {
  default        = "creating sg for frontend instance"
}
