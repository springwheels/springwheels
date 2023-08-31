
resource "aws_s3_bucket_policy" "example-policy" {
  bucket = aws_s3_bucket.website.id
  policy = templatefile("s3-policy.json", { bucket = var.website_bucket_name })
  depends_on = [
    aws_s3_bucket_public_access_block.example,
    aws_s3_bucket_ownership_controls.example,
  ]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_public_access_block.example,
    aws_s3_bucket_ownership_controls.example,
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}

# AWS S3 bucket for static hosting
resource "aws_s3_bucket" "website" {
  bucket = var.website_bucket_name

}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.website.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


resource "aws_s3_object" "object-upload-html" {
  for_each     = fileset("springwheels.net/", "*.html")
  bucket       = aws_s3_bucket.website.bucket
  key          = each.value
  content_type = "text/html"
  source       = "springwheels.net/${each.value}"
  etag         = filemd5("springwheels.net/${each.value}")
}

resource "aws_s3_object" "object-upload-png" {
  for_each     = fileset("springwheels.net/", "*.png")
  bucket       = aws_s3_bucket.website.bucket
  key          = each.value
  content_type = "image/png"
  source       = "springwheels.net/${each.value}"
  etag         = filemd5("springwheels.net/${each.value}")
}

resource "aws_s3_object" "object-upload-js" {
  for_each     = fileset("springwheels.net/", "*.js")
  bucket       = aws_s3_bucket.website.bucket
  key          = each.value
  content_type = "text/javascript"
  source       = "springwheels.net/${each.value}"
  etag         = filemd5("springwheels.net/${each.value}")
}

