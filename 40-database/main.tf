# mongodb instance creation
resource "aws_instance" "mongodb" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id]
  subnet_id              = local.database_subnet_id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.Name}-mongodb"
    }
  )
}

# mongodb configuration using ansible-pull 
resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mongodb.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb"
    ]
  }
}



# redis instance creation
resource "aws_instance" "redis" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.redis_sg_id]
  subnet_id              = local.database_subnet_id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.Name}-redis"
    }
  )
}

# redis configuration using ansible-pull 
resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.redis.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis"
    ]
  }
}



# mysql instance creation
resource "aws_instance" "mysql" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mysql_sg_id]
  subnet_id              = local.database_subnet_id
  iam_instance_profile = "EC2RoleToFetchSSMParams"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.Name}-mysql"
    }
  )
}

# mysql configuration using ansible-pull 
resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.mysql.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql"
    ]
  }
}



# rabbitmq instance creation
resource "aws_instance" "rabbitmq" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.rabbitmq_sg_id]
  subnet_id              = local.database_subnet_id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.Name}-rabbitmq"
    }
  )
}

# rabbitmq configuration using ansible-pull 
resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id
  ]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.rabbitmq.private_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq"
    ]
  }
}


# Create a Route 53 Hosted Zone
resource "aws_route53_zone" "my_zone" {
  name = "gonela.site" # Replace with your domain name
}

# to get name servers of hosted zone
data "aws_route53_zone" "selected" {
  # name         = "gonela.site" # Replace with your domain name
  # or
  zone_id = aws_route53_zone.my_zone.id           #"Z2FDTNDUVT1FRY"  Replace with your hosted zone ID
}

#outputs of hosted zone name servers
output "name_servers" {
  value = data.aws_route53_zone.selected.name_servers
}

resource "aws_route53_record" "mongodb" {
  zone_id   = aws_route53_zone.my_zone.id
  name      = "mongodb.${data.aws_route53_zone.selected.name}"
  type      = "A"
  ttl       = 1
  records   = [aws_instance.mongodb.private_ip]
  allow_overwrite =  true
}

resource "aws_route53_record" "redis" {
  zone_id   = aws_route53_zone.my_zone.id
  name      = "redis.${data.aws_route53_zone.selected.name}"
  type      = "A"
  ttl       = 1
  records   = [aws_instance.redis.private_ip]
  allow_overwrite =  true
}

resource "aws_route53_record" "mysql" {
  zone_id   = aws_route53_zone.my_zone.id
  name      = "mysql.${data.aws_route53_zone.selected.name}"
  type      = "A"
  ttl       = 1
  records   = [aws_instance.mysql.private_ip]
  allow_overwrite =  true
}

resource "aws_route53_record" "rabbitmq" {
  zone_id   = aws_route53_zone.my_zone.id
  name      = "rabbitmq.${data.aws_route53_zone.selected.name}"
  type      = "A"
  ttl       = 1
  records   = [aws_instance.rabbitmq.private_ip]
  allow_overwrite =  true
}