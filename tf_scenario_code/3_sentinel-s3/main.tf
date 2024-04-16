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
