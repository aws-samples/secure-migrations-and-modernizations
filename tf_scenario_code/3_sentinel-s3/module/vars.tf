

variable "s3_ownership" {}
variable "s3_acl" {}
variable "s3_block_public_acls" {
  type = bool
}
variable "s3_block_public_policy" {
  type = bool
}
variable "s3_ignore_public_acls" {
  type = bool
}
variable "s3_restrict_public_buckets" {
  type = bool
}

variable "s3_sse_algorithm" {
  type        = string
  description = "AES256 or aws:kms"
}


locals {
  s3_ownership                         = var.s3_ownership
  s3_acl                               = var.s3_acl
  s3_block_public_acls                 = var.s3_block_public_acls
  s3_block_public_policy               = var.s3_block_public_policy
  s3_ignore_public_acls                = var.s3_ignore_public_acls
  s3_restrict_public_buckets           = var.s3_restrict_public_buckets
  s3_sse_algorithm                     = var.s3_sse_algorithm

  tags = {
  }
}