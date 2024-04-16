resource "random_id" "bucket-suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3-bucket-sentinel" {
  bucket = "s3-bucket-sentinel-${random_id.bucket-suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "s3-bucket-ownership" {
  bucket = aws_s3_bucket.s3-bucket-sentinel.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3-bucket-ownership]

  bucket = aws_s3_bucket.s3-bucket-sentinel.id
  acl    = var.acl_disabled ? "private" : "public-read"
}

#resource "aws_s3_bucket_public_access_block" "s3-bucket-public-access" {
#  bucket = aws_s3_bucket.s3-bucket-sentinel.id

#  block_public_acls       = false
#  block_public_policy     = false
#  ignore_public_acls      = false
#  restrict_public_buckets = false
#}
