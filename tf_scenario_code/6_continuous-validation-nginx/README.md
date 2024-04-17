---
title: "Continuous Validation"
weight: 30
---

## 아키텍쳐 오버뷰

![architecture-6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-6.png?raw=true)

## AWS 모범사례

* [MIG-SEC-BP-10.1: AWS 기본 모니터링 도구 검증 및 사용s](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/mobilize-sec.html#mig-sec-bp-10.1-validate-and-use-monitoring-tools)

---

## Continuous Validation

![continuousvalidation.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/continuousvalidation.png?raw=true)

이번 실습에서는 Web Server가 비정상 동작할 때 `Terraform continuous validation` 기능을 통해 이러한 상황을 탐지하는 것을 확인합니다.

## Workshop 선택하기
**Projects & workspaces** 에서 `6_Continuous_Validation`를 선택합니다.
![3_4_0_select_workshop.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_0_select_workshop.png?raw=true)

## Web Server(NGNIX)를 위한 EC2 Instance와 Security Group 생성
1. Hashicorp 워크샵의 `New run` 버튼을 눌러 Trail을 생성합니다. (Terraform IaC 프로비져닝)
![3_4_0_new_run.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_0_new_run.png?raw=true)

2. [EC2 instance Console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances:instanceState=running)로 이동하여 instance 생성을 확인합니다. (Name: `6_continus-validation`)
![3_4_1_check_ec2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_1_check_ec2.png?raw=true)

## Web Server 동작 확인
3. Public IPv4 DNS의 주소를 사용하여 Web Server 동작을 확인합니다.
    - Public IPv4 DNS 확인합니다.
    ![3_4_2_check_address.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_2_check_address.png?raw=true)
    - 해당 주소는 https를 지원하고 있지 않습니다. 다름과 같이 주소를 구성하여 웹 브라우저의 
        - 주소창에 입력합니다. http://`복사한 Public IPv4 DNS`
    - Web Server 동작 확인
    ![3_4_3_check_browser.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_3_check_browser.png?raw=true)
    
4. Hashicorp 워크샵의 Health → Continuous Validation으로 이동하여 **Start health assessment**를 클릭합니다.
![3_4_4_start_health_assessment.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_4_start_health_assessment.png?raw=true)

## Web Server를 정지시킨 후 Continuous Validation 확인하기
5. EC2 Instance에 접속하여 NGNIX를 정지합니다.
    * EC2 Instance에 접속합니다.
    ![3_4_5_connect_to_ec2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_5_connect_to_ec2.png?raw=true)
    ![3_4_6_connect_to_ec2_2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_6_connect_to_ec2_2.png?raw=true)

    * NGINX 동작을 확인합니다.
        ```bash
        sudo systemctl status nginx
        ```
        ![3_4_7_check_nginx_status.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_7_check_nginx_status.png?raw=true)

    * NGINX를 정지시킵니다.
        ```bash
        sudo systemctl stop nginx
        ```
        ![3_4_8_stop_nginx.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_8_stop_nginx.png?raw=true)
6. Hashicorp 워크샵의 Health → Continuous Validation으로 이동하여 상태를 확인합니다. assert 로직에 ec2 instance의 상태와 ngninx의 응답 코드 확인 부분을 넣음으로써 nginx에 문제가 있음이 탐지되었습니다.  **check.response.ngix** 의 health 체크가 실패했습니다. 

> Continuous Validation 에서 자동으로 감지하나 **Start health assessment**를 클릭하여 대기 시간을 최소화하며 워크샵을 진행해주세요.]

![3_4_9_check_continuous_validation](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_9_check_continuous_validation.png?raw=true)

7. EC2 Instance에 접속하여 NGINX의 상태를 먼저 확인하기 위해 아래의 명령어를 수행하면 NGNIX가 `inactive`상태임을 확인되었습니다. 

```bash
sudo systemctl status nginx
```

![3/4/3_4_10_ngniz_status](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_10_ngniz_status.png?raw=true)

8. 아래의 명령어를 실행하여 NGNIX를 재기동합니다.

```bash
sudo systemctl start nginx
```

![3_4_11_ngniz_restart](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_11_ngniz_restart.png?raw=true)

9. Hashicorp 워크샵의 Health → Continuous Validation으로 이동하여 상태를 확인합니다. **check.response.ngix** 의 health 체크가 정상적으로 통과했습니다. 

> Continuous Validation 에서 자동으로 감지하나 **Start health assessment**를 클릭하여 대기 시간을 최소화하며 워크샵을 진행해주세요.

![3_4_12_cv_healthy](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/4/3_4_12_cv_healthy.png?raw=true)


> Drift Detection은 AWS 리소스의 구성 정보에 대한 거버넌스 그리고 Continuous Validation은 OS, 서비스, 애플리케이션에 대해서 지속적인 거버넌스를 가질 수 있습니다. 


---
## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/6_continuous-validation-nginx)에서도 보실 수 있습니다.]

### check.tf

```ruby
check "response_nginx" {
  data "http" "nginx" {
   url      = "http://${aws_instance.ec2.public_dns}"

  depends_on = [time_sleep.wait_15_seconds]
  # depends_on = [check.response_ec2_running]
}

  assert {
    condition     = data.http.nginx.status_code == 200
    error_message = "Nginx Status Code가 ${data.http.nginx.status_code} 으로 정상적이지 않습니다."
  }
}

check "response_ec2_running" {

  assert {
    condition     = aws_instance.ec2.instance_state == "running"
    error_message = "EC2 인스턴스가 Running 상태가 아닙니다."
  }
}
```

### main.tf
```ruby
data "aws_ami" "al2023_arm" {
  most_recent = true

  owners = ["amazon"]
  
  filter {
    name = "image-id"
    values = var.ami_id
    # ami-0c031a79ffb01a803는 x86_64 이미지
    # ami-0c1f7b7eb05c17ca5는 arm64 이미지
  }
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id[0] # Graviton3 기본 이미지 사용
  instance_type = var.ec2_type
  key_name      = var.ec2_key
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ngnix-sg.id]
  lifecycle {
    # AMI 이미지는 ARM 아키텍처만 사용해야 함
    precondition {
      condition     = data.aws_ami.al2023_arm.architecture == "arm64"
      error_message = "AMI 이미지는 반드시 ARM 64 기반의 이미지어야 합니다. 예) ami-0c1f7b7eb05c17ca5"
    }
  }
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

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_instance.ec2]
  create_duration = "30s"
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
}
```

### provider.tf
```ruby
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=5.20.0"
    }
  }
}

provider "aws" {
    region = var.region
}
```

## vars.tf
```ruby
variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable ec2_type {
  type = string
  default = "m7g.medium"
}

variable ami_id {
  type = list(string)
  default = ["ami-0c1f7b7eb05c17ca5"]
  # default = ["ami-0c031a79ffb01a803"]
  description = "Amazon Linux 2023 AMI ARM64 지원 AMI"
}
```


> 모든 실습을 완료하셨습니다. 수고하셨습니다! **Next** 버튼을 눌러주세요.


