variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "instance_type" {
  type    = string
  default = "m5.large"
}

variable "ami_type" {
  type        = string
  default     = "arm64"
  description = "amd64 or arm64"
}