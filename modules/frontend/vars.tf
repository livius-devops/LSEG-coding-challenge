variable "cloudfront_s3_config" {
  description = "Configuration object for CloudFront and S3"
  type = object({
    s3_bucket_name                  = string
    default_root_object             = string
    cloudfront_origin_access_identity = string
    alb_dns_name                    = string        
    redirect_to_alb_path            = string        
    domain_name                     = string
  })
}

