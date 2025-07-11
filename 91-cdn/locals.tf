locals {
    common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
  
  Name        = "${var.project}-${var.environment}"

  cacheDisabled = data.aws_cloudfront_cache_policy.cacheDisabled.id
  cacheEnabled = data.aws_cloudfront_cache_policy.cacheEnabled.id
  acm_certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value
 
  zone_name   = data.aws_route53_zone.selected.name
  zone_id    = data.aws_route53_zone.selected.zone_id

}