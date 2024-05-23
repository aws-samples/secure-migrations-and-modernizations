resource "aws_instance" "ec2" {
  ami           = var.ami_id[0]
  instance_type = var.ec2_type

  vpc_security_group_ids = [aws_security_group.sentinel-test-sg.id]

  tags = {
    Name = "ec2-2_sentinel_sg"
  }
}

resource "aws_security_group" "sentinel-test-sg" {
  name        = "sentinel-test-sg"
  description = "Security group for testing terraform sentinel"

  tags = {
    Name = "2_sentinel-sg"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [var.cidr_blocks]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}