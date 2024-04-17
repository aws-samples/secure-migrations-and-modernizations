variable "region" {
  type = string
  default = "ap-northeast-2"
}

# variable ec2_key {
#   type = string
#   default = "key-pair"
# }

variable ec2_type {
  type = string
  default = "t3.micro"
}

variable ami_id {
  type = list(string)
  # default = ["ami-0c1f7b7eb05c17ca5"]
  default = ["ami-0c031a79ffb01a803"]
  description = "x86"
}