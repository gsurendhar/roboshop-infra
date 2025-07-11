data "aws_ssm_parameter" "acm_certificate_arn"{
  name = "/${var.project}/${var.environment}/acm_certificate_arn"
}

data "aws_cloudfront_cache_policy" "cacheEnabled" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "cacheDisabled" {
  name = "Managed-CachingDisabled"
}


data "aws_route53_zone" "selected" {
  name         = "gonela.site" # Replace with your domain name
  # or
  # zone_id = aws_route53_zone.my_zone.id           #"Z2FDTNDUVT1FRY"  Replace with your hosted zone ID
}