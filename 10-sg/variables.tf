variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

# variable "vpc_id" {
#   default        = string
# }

variable "sg_name" {
  default = "frontend"
}

variable "sg_description" {
  default = "creating sg for frontend instance"
}

variable "vpn_ports" {
  default = [22, 443, 943, 1194]
}

variable "mongodb_ports_vpn" {
  default = [22, 27017]
}

variable "redis_ports_vpn" {
  default = [22, 6379]
}

variable "mysql_ports_vpn" {
  default = [22, 3306]
}

variable "rabbitmq_ports_vpn" {
  default = [22, 5672]
}