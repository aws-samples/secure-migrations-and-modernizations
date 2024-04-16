resource "random_id" "example" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3" {
  bucket = "example-bucket-${random_id.example.hex}"
  # acl    = var.acl_enabled ? "private" : "public-read" # ACL을 활성화 또는 비활성화합니다.

  tags = {
    Name        = "ExampleBucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = local.s3_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = local.s3_block_public_acls
  block_public_policy     = local.s3_block_public_policy
  ignore_public_acls      = local.s3_ignore_public_acls
  restrict_public_buckets = local.s3_restrict_public_buckets
}

resource "aws_s3_bucket_acl" "s3" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3,
    aws_s3_bucket_public_access_block.s3,
  ]

  bucket = aws_s3_bucket.s3.id
  acl    = local.s3_acl
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.s3_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy_for_s3_policy" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.iam_policy_for_s3_policy.json
}

data "aws_iam_policy_document" "iam_policy_for_s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.s3.arn,
      "${aws_s3_bucket.s3.arn}/*",
    ]
  }
}
