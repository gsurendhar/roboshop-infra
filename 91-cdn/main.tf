
resource "aws_cloudfront_distribution" "roboshop" {
  origin {
    domain_name  = "cdn.${local.zone_name}"
    origin_id    = "cdn.${local.zone_name}"
    custom_origin_config {
      http_port  = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true

  aliases = ["cdn.${local.zone_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "cdn.${local.zone_name}"

    viewer_protocol_policy = "https_only"
    cache_policy_id = local.cacheDisabled

  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/media/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "cdn.${local.zone_name}"

    viewer_protocol_policy = "https_only"
    cache_policy_id = local.cacheEnabled
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = merge (
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )

  viewer_certificate {
    cloudfront_default_certificate = local.acm_certificate_arn
  }
}

resource "aws_route53_record" "cdn" {
    zone_id = local.zone_id
    name = "cdn.${local.zone_name}"
    type = "A"
    alias {
        name = aws_cloudfront_distribution.roboshop.domain_name
        zone_id = aws_cloudfront_distribution.roboshop.hosted_zone_id
        evaluate_target_health =true
    }
}