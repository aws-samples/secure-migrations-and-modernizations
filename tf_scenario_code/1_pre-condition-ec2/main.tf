data "aws_ami" "al2023_arm" {
  most_recent = true

  owners = ["amazon"]
  
  filter {
    name = "image-id"
    values = var.ami_id
    # ami-0c031a79ffb01a803는 사용자가 배포하려는 x86_64 이미지
    # ami-0c1f7b7eb05c17ca5는 사내 보안팀이 검증하고 승인한 arm64 이미지
  }
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id[0] # Graviton3 기본 이미지 사용
  instance_type = var.ec2_type
  # key_name      = var.ec2_key
  associate_public_ip_address = true

  lifecycle {
    # AMI 이미지는 ARM 아키텍처만 사용해야 함
    precondition {
      condition     = data.aws_ami.al2023_arm.architecture == "arm64"
      error_message = "AMI 이미지는 반드시 사내 보안팀이 검증한 ami-0c1f7b7eb05c17ca5 이어야 합니다"
    }
  }
  tags = {
    Name = "GravitonServerWithAmazonLinux2023"
  }
}
