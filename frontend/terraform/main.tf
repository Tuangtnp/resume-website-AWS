resource "aws_s3_bucket" "resume_bucket_website" {
  bucket = var.resume_bucket_name

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "resume_bucket_versioning" {
  bucket = aws_s3_bucket.resume_bucket_website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "resume_bucket_web_config" {
  bucket = aws_s3_bucket.resume_bucket_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "resume_bucket_public_access" {
  bucket = aws_s3_bucket.resume_bucket_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket_website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "CloudFrontReadGetObject",
      Effect = "Allow",
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.resume_origin_identity.iam_arn
      }
      Action   = "s3:GetObject",
      Resource = "${aws_s3_bucket.resume_bucket_website.arn}/*"
    }]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "resume_bucket_website_lifecycle" {
  bucket = aws_s3_bucket.resume_bucket_website.id

  rule {
    id = "delete-old-non-current"
    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 1
      noncurrent_days           = 3
    }

    status = "Enabled"
  }
}

resource "aws_cloudfront_distribution" "resume_cdn" {
  origin {
    domain_name = aws_s3_bucket.resume_bucket_website.bucket_regional_domain_name
    origin_id   = "S3FrontendOrigin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.resume_origin_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for resume site"
  default_root_object = "index.html"

  aliases = [var.resume_domain, "www.${var.resume_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3FrontendOrigin"
    compress         = true

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.resume_acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project = "Resume"
    Manage  = "Terraform"
  }

  depends_on = [aws_s3_bucket.resume_bucket_website]
}

resource "aws_cloudfront_origin_access_identity" "resume_origin_identity" {
  comment = "Cloudfront access identity for S3 website bucket"
}
