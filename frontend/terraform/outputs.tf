output "bucket_name" {
  value = aws_s3_bucket.resume_bucket_website.bucket_domain_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.resume_cdn.domain_name
}
