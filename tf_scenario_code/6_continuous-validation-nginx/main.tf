resource "aws_instance" "ec2" {
  ami           = var.ami_id[0]
  instance_type = var.ec2_type
  # key_name      = var.ec2_key
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ngnix-sg.id]
  
  tags = {
    Name = "6_continus-validation"
  }
  user_data = <<-EOF
    #!/bin/bash
    yum install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
    EOF
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [aws_instance.ec2]
  create_duration = "15s"
}

output "ec2_public_dns" {
  value = aws_instance.ec2.public_dns
}


resource "aws_security_group" "ngnix-sg" {
  name   = "ngnix-sg"
  description = "Security group for testing terraform enterprise drift detection"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "6_continus-validation-nginx"
  }
}
