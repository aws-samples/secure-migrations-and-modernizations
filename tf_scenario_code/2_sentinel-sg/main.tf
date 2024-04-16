resource "aws_instance" "ec2" {
  ami           = var.ami_id[0]
  instance_type = var.ec2_type
  # key_name      = var.ec2_key
  # associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sentinel-test-sg.id]

  tags = {
    Name = "ec2-2_sentinel_sg"
  }
}

resource "aws_security_group" "sentinel-test-sg" {
  name   = "sentinel-test-sg"
  description = "Security group for testing terraform sentinel"

  tags = {
    Name = "2_sentinel-sg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    
    ## 보안 취약점: 인터넷에 대한 액세스를 제어하지 않음
    # cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["192.168.0.0/16"]
    cidr_blocks = [var.cidr_blocks]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    
    # cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [var.cidr_blocks]
    description = "Allow all outbound traffic"
  }
}