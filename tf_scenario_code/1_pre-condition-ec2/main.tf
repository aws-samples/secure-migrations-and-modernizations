data "aws_ami" "ubuntu_22" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.ami_type}-server-*"]
  }
}

resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  lifecycle {
    precondition {
      condition     = contains(["t3.micro", "t3.large", "m6i.midium", "m6i.large"], var.instance_type)
      error_message = "허용된 instance_type 은 t3.micro, t3.large, m6i.midium, m6i.large 입니다."
    }
    precondition {
      condition     = data.aws_ami.ubuntu_22.architecture == "x86_64"
      error_message = "AMI 이미지는 aws_instance_type이 x86_64이므로 x86_64 아키텍쳐여야 합니다."
    }
  }
  tags = {
    Name = "Ubuntu_22.04"
  }
}

### 기존 코드 생략 ###

resource "aws_instance" "ec2_postcondition" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  lifecycle {
    precondition {
      condition     = contains(["t3.micro", "t3.large", "m6i.midium", "m6i.large"], var.instance_type)
      error_message = "허용된 instance_type 은 t3.micro, t3.large, m6i.midium, m6i.large 입니다."
    }
    precondition {
      condition     = data.aws_ami.ubuntu_22.architecture == "x86_64"
      error_message = "AMI 이미지는 aws_instance_type이 x86_64이므로 x86_64 아키텍쳐여야 합니다."
    }
    postcondition {
      condition     = self.root_block_device[0].encrypted == true
      error_message = "root block device는 암호화 설정이 되어있어야 합니다."
    }
  }
  tags = {
    Name = "Ubuntu_22.04_PostCondition"
  }
}
