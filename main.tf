locals {
  default_tags = {
    project     = "theden-static-website"
    environment = "development"
  }
  s3_origin_id = "theden-static-website-${local.default_tags.environment}"
}

resource "aws_s3_bucket" "theden_static_website" {
  bucket = "theden-static-website"
  tags   = local.default_tags
}

resource "aws_s3_bucket_acl" "theden_static_website_acl" {
  bucket = aws_s3_bucket.theden_static_website.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "theden_static_website_policyt" {
  bucket = aws_s3_bucket.theden_static_website.id
  policy = data.aws_iam_policy_document.theden-static-website_policy_document.json
}

data "aws_iam_policy_document" "theden-static-website_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.theden_static_website.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_object" "bucket_index" {
  bucket       = aws_s3_bucket.theden_static_website.bucket
  key          = "index.html"
  source       = "${path.root}/bucket_data/index.html"
  etag         = filemd5("${path.root}/bucket_data/index.html")
  content_type = "text/html"

}

resource "aws_cloudfront_origin_access_control" "s3_access" {
  name                              = "s3-access-contrl"
  description                       = "CloudFront Origin Access control for s3 buckets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    # Domain will be <bucketname>.s3.<region>.amazonaws.com via the attribute
    domain_name              = aws_s3_bucket.theden_static_website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_access.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website S3 origin"
  default_root_object = "index.html"
  http_version        = "http2and3"

  default_cache_behavior {
    # Using "CachingOptimized" managed policy ID
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["AU"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.default_tags
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = try(aws_s3_bucket.theden_static_website.id, "")
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = try(aws_s3_bucket.theden_static_website.arn, "")
}

output "cloudfront_etag" {
  description = "CloudFront Distribution ID"
  value       = try(aws_cloudfront_distribution.s3_distribution.etag, "")
}

output "static_website_url" {
  description = "URL for the static website"
  value       = try("https://${aws_cloudfront_distribution.s3_distribution.domain_name}", "")
}
