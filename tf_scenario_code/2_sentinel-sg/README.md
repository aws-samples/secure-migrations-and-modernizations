---
title: "네트워크 트래픽 제어"
weight: 22
---
## 아키텍쳐 오버뷰

![architecture-2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-2.png?raw=true)

## 마이그레이션 보안 요구사항(MSR) - Infrastructure Protection 
* MSR.IP.13 - security groups은 승인된 CIDR/포트에 대해서만 트래픽이 허락되도록 구성되어 있나요?

모빌라이즈 단계에서부터 security groups의 규칙은 최소 권한 액세스 원칙을 따라야 합니다. 액세스가 제한되지 않은 경우,(접미사가 /0인 IP 주소)는 해킹, 서비스 거부 공격, 데이터 손실과 같은 악의적인 활동의 기회를 증가시킵니다. 허용되지 않은 포트를 통해 트래픽이 들어오는 경우에도 액세스를 제한해야 합니다.

## AWS 모범사례

* [MIG-SEC-BP-6.2 네트워크 보안 제어 설정](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/mobilize-sec.html#mig-sec-bp-6.2-establish-network-security-controls)
* [MIG-SEC-BP-15.1: 네트워크 리소스 보호](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-sec.html#mig-sec-bp-15.1-protect-your-network-resources)
* [SEC05-BP02 모든 계층에서 트래픽 제어](https://docs.aws.amazon.com/ko_kr/wellarchitected/latest/security-pillar/sec_network_protection_layered.html)


## Terraform Sentinel을 통해 프로비저닝 워크플로우 내에서 MSR의 코드형 정책을 구현하기

Terraform으로 리소스 프로비져닝이 IaC되어 있기에 MSR.IP.13에 대한 정책을 Sentinel Policies로 정의하여 프로비져닝 전에 MSR.IP.13을 만족하는지 검증합니다.  

![Images/sentinel.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sentinel.png?raw=true)

> 본 워크샵에서는 [Sentinel Policies](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/sentinel)은 사전에 생성되고 적용되어 있습니다. 어떻게 Sentinel Policies를 생성하는지에 대한 실습은 진행하지 않습니다. 본 워크샵에서 사용되는 Sentinel Policies 정책은 [여기](https://github.com/kr-partner/aws-partner-summit-tfcode/blob/main/tf_sentinel_code/sentinel-policy-sg/terraform-restrict-sg.sentinel)를 참조해주세요.

---

## AWS 컴퓨트 리소스와 security groups 생성 

1. **Projects & workspaces** 에서 `2_Sentinel_sg`를 선택합니다

![Images/sg-0.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-0.png?raw=true)

2. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/sg-1.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-1.png?raw=true)

3. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/sg-2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-2.png?raw=true)

4. 이번에는 MSR의 조건이 [Sentinel Policy](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/275a171d230d22ca38294696f22ae3c4fdf4c890/tf_sentinel_code/sentinel-policy-sg/terraform-restrict-sg.sentinel#L95) 로 정의가 되어 있기에 `terraform plan`은 성공했지만 `Sentinel policies`에서 실패합니다. 이는 Sentinel Policy에서 security groups의 cidr이 `0.0.0.0/0` 정의된 경우, 프로비져닝가 진행되지 않고 종료가 됩니다. [Enforcement mode](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/main/tf_sentinel_code/sentinel-policy-sg/sentinel.hcl)는 반드시 만족해야하는 **hard-mandatory**로 정의되어 있습니다. 

> [Sentinel](https://developer.hashicorp.com/sentinel/docs/concepts/policy-as-code)의 Policy as Code 그리고 Enforcement Levels는 [여기](https://developer.hashicorp.com/sentinel/docs/concepts/enforcement-levels)를 참조해주세요.

![Images/sg-3.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-3.png?raw=true)

5. 보안팀은 특정 IP 대역인 192.168.0.100/32 만을 허용한다고 가정하겠습니다. 따라서, **Variable** 메뉴로 이동해서 **Edit variable**을 선택후, **cidr_blocks** 값을 해당 cidr 로 변경해야 합니다.

![Images/sg-4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-4.png?raw=true)

6. `192.168.0.100/32` 로 변경후, **Save variable** 클릭해 저장하세요. 

```bash
192.168.0.100/32
```

![Images/sg-5.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-0.png?raw=true)

7. 왼쪽 메뉴바에서 **New run**을 누른 후, 다시 **Start**를 클릭하세요.

![Images/sg-6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-6.png?raw=true)

8. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/sg-7.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-7.png?raw=true)

9. Terraform Plan 이 이번에는 정상적으로 작동함을 볼 수 있습니다. 승인된 이미지 그리고 승인된 인스턴스 타입만이 Terraform Plan을 성공적으로 마칠 수 있기에 보안 요구사항을 Shift Left한 결과를 의미합니다. 참고로 인스턴스의 예상 비용도 확인할 수 있습니다. 프로비져닝를 위해 **Confirm & apply**를 선택하세요.

![Images/sg-8.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-8.png?raw=true)

10.  Comment 추가후, **Comfirm plan** 을 클릭하세요. 

![Images/sg-9.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-9.png?raw=true)

11.  [AWS EC2 console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances)에서 `ec2-2_sentinel_sg`라는 새로운 EC2 Instance 가 프로비져닝되었고 security groups의 **inbound rules**는 `192.168.0.100/32`로 설정이 되어있음을 확인 할 수 있습니다. 

![Images/sg-10.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/network/sg-10.png?raw=true)

## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/2_sentinel-sg)에서도 보실 수 있습니다.

모빌라이즈 단계에서 EC2 인스턴스를 프로비져닝시 security groups의 cidr 설정이 과대하게 열려있는지 확인하고 보안팀의 정책에 맞는 구성인지 모든 프로비져닝시 지속적으로 validation 해야합니다.

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
  vpc_security_group_ids = [aws_security_group.sentinel-test-sg.id]
  
  lifecycle {
    # AMI 이미지는 ARM 아키텍처만 사용해야 함
    precondition {
      condition     = data.aws_ami.al2023_arm.architecture == "arm64"
      error_message = "AMI 이미지는 반드시 ARM 64 기반의 이미지어야 합니다. 예) ami-0c1f7b7eb05c17ca5"
    }
  }

  tags = {
    Name = "ec2-2_sentinel_sg"
  }
}

resource "aws_security_group" "sentinel-test-sg" {
  name   = "sentinel-test-sg"
  description = "Security group for testing terraform sentinel"

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

  tags = {
    Name = "2_sentinel-sg"
  }
}
```

### var.tf

```ruby
variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "cidr_blocks" {
  type = string
  default = "0.0.0.0/0"
}

variable ec2_key {
  type = string
  default = "DPT-Vault-kp-common"
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


> security groups의 최소 권한 액세스를 Sentinel policy에 정의하여 cidr이 지나치게 관대하게 오픈되는 경우를 사전에 방지합니다. 다음 실습을 위해서 **Next**를 클릭해 주세요.