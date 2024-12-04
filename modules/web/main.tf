resource "aws_s3_bucket" "web_app_bucket" {
  bucket = "${lower(var.env)}-${lower(replace(var.app_name, "_", "-"))}"

  tags = {
    Name = "${lower(var.env)}-${lower(replace(var.app_name, "_", "-"))}"
    Env  = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "web_app_bucket_public_access" {
  bucket = aws_s3_bucket.web_app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "web_app_bucket_policy" {
  bucket = aws_s3_bucket.web_app_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          "${aws_s3_bucket.web_app_bucket.arn}",
          "${aws_s3_bucket.web_app_bucket.arn}/*"
        ]
      },
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_app_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "web_app_bucket_cors" {
  bucket = aws_s3_bucket.web_app_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "web_app_bucket_website" {
  bucket = aws_s3_bucket.web_app_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.env}-${var.app_name}-web-app"
}

resource "aws_cloudfront_distribution" "web_app_distribution" {
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.web_app_bucket.bucket_regional_domain_name
    origin_id   = "${var.env}-${var.app_name}-web-app-bucket-origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  enabled = true
  comment = "CloudFront distribution for ${var.env}-${var.app_name}"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.env}-${var.app_name}-web-app-bucket-origin"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }
  
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.env}-${var.app_name}-web-app-distribution"
  }
}
