##!!Validation step is also needed but it will fail as I cannot mock it !!
resource "aws_acm_certificate" "this" {
  domain_name       = var.cloudfront_s3_config.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
# S3 Bucket for static content
resource "aws_s3_bucket" "this" {
  bucket = var.cloudfront_s3_config.s3_bucket_name
  acl    = "public-read"  # Set to private if you want to restrict access

  tags = {
    Name = "S3 Bucket for CloudFront"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = "S3-${var.cloudfront_s3_config.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = var.cloudfront_s3_config.cloudfront_origin_access_identity != "" ? var.cloudfront_s3_config.cloudfront_origin_access_identity : null
    }
  }

  # Add ALB as a second origin if ALB settings are provided
  dynamic "origin" {
    for_each = var.cloudfront_s3_config.alb_dns_name != "" ? [1] : []
    content {
      domain_name = var.cloudfront_s3_config.alb_dns_name
      origin_id   = "ALB-${var.cloudfront_s3_config.alb_dns_name}"

      custom_origin_config {
        http_port             = 80
        https_port            = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols  = ["TLSv1.2", "TLSv1.3"]  # Specifying SSL protocols
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.cloudfront_s3_config.default_root_object

  # Default cache behavior (S3 bucket)
  default_cache_behavior {
    target_origin_id = "S3-${var.cloudfront_s3_config.s3_bucket_name}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]  # Methods allowed for this cache behavior
    cached_methods = ["GET", "HEAD"]  # Cached methods

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Conditional certificate reference
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"  # Default, no geo restrictions
    }
  }
}
