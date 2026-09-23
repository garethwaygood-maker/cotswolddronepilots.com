resource "aws_s3_bucket" "cdp_website" {
  bucket = "cdp.waygood.net"
}
resource "aws_cloudfront_origin_access_control" "cdp_oac" {
  name                              = "oac-cdp.waygood.net.s3.eu-west-2.amazonaws.com-mtyh03qo35j"
  description                       = "Created by CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "cdp_distribution" {

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cotswold Drone Pilots website"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  http_version        = "http2"

  tags = {
    Name = "cdp-waygood-net"
  }
  aliases = [
    "cdp.waygood.net"
  ]

  origin {
    domain_name              = "cdp.waygood.net.s3.eu-west-2.amazonaws.com"
    origin_id                = "cdp.waygood.net.s3.eu-west-2.amazonaws.com-mtygu5lswxr"
    origin_access_control_id = aws_cloudfront_origin_access_control.cdp_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "cdp.waygood.net.s3.eu-west-2.amazonaws.com-mtygu5lswxr"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:561945082889:certificate/5b5442d7-206c-4aa3-9540-6b9ca30d37be"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = "arn:aws:wafv2:us-east-1:561945082889:global/webacl/CreatedByCloudFront-8acef746/26660def-78eb-4792-ba24-8bcf46c4a7bb"
}
resource "aws_acm_certificate" "cdp_certificate" {
  provider = aws.us_east_1

  domain_name       = "cdp.waygood.net"
  validation_method = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}
resource "aws_route53_record" "cdp_ipv4" {
  zone_id = "Z06029927TI3CWVLZ1VG"
  name    = "cdp.waygood.net"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdp_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cdp_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cdp_ipv6" {
  zone_id = "Z06029927TI3CWVLZ1VG"
  name    = "cdp.waygood.net"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cdp_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cdp_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cdp_certificate_validation" {
  zone_id = "Z06029927TI3CWVLZ1VG"
  name    = "_69a51bad6e7a78e525a201318595a045.cdp.waygood.net"
  type    = "CNAME"
  ttl     = 300

  records = [
    "_710c1da3af5b61fede652a4824445b63.wzccmgtwzk.acm-validations.aws."
  ]
}