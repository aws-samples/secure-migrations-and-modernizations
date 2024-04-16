variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable ec2_key {
  type = string
  default = "hw-key"
}
variable ec2_type {
  type = string
  default = "m7g.medium"
}

variable ami_id {
  type = list(string)
  # default = "ami-0c1f7b7eb05c17ca5"
  default = ["ami-0c031a79ffb01a803"]
  description = "Amazon Linux 2023 AMI ARM64 지원 AMI"
}

variable ami_name_filter {
  type = string
  default = "*al2023*-arm64"
  # default = "*al2023*-x86_64"
  description = "Amazon Linux 2023 AMI ARM64 지원 AMI"
}