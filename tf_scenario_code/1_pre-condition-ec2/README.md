---
title: "컴퓨트 리소스의 attack surface 최소화"
weight: 21
---

## 아키텍쳐 오버뷰

![architecture-1.png](./static/architecture/architecture-1.png?classes=lab_picture_small)

## 마이그레이션 보안 요구사항(MSR) - Infrastructure Protection 
* MSR.IP.1 - 마이그레이션 전후에 취약성 평가를 수행했나요?

모빌라이즈 단계에서부터 AWS 에서 사용 할 운영 체제를 강화하고 사용 중인 구성 요소와 외부 서비스를 최소화하여 의도하지 않은 액세스에 대한 노출을 최소화합니다. Amazon EC2의 경우, 패치를 적용한 Hardened AMI(Amazon Machine Image)를 생성할 수 있습니다. 이는 조직의 특정 보안 요구 사항을 충족할 수 있으며 인더스트리의 컴플라이언스를 만족하는 이미지를 사용해야하는 경우도 있습니다. 

AMI에 적용하는 패치 및 기타 보안 제어 조치는 생성 시점에 발효되며 시작한 후 AWS Systems Manager 등을 사용하여 수정하지 않는 이상 동적으로 변경되지 않습니다. 예를 들면, [Center for Internet Security(CSI)](https://aws.amazon.com/marketplace/seller-profile?id=dfa1e6a8-0b7b-4d35-a59c-ce272caee4fc&ref=dtl_B07M68CJS5)에서 시작하고 반복하면 됩니다.

AWS는 취약성 관리 프로그램에 도움이 되는 다양한 서비스를 제공합니다. Amazon Inspector는 AWS 워크로드에서 소프트웨어 문제와 의도하지 않은 네트워크 액세스를 지속적으로 검사합니다. AWS Systems Manager는 Amazon EC2 인스턴스 전반의 패치 관리를 지원합니다.

## AWS 모범사례
* [MIG-SEC-BP-2.1 모빌라이즈시 사용할 도구(tool)들을 매핑 수행](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/assess-sec.html#mig-sec-bp-2.1-perform-a-tools-mapping-exercise)
* [SEC06-BP02 공격 표면 축소](https://docs.aws.amazon.com/ko_kr/wellarchitected/latest/security-pillar/sec_protect_compute_reduce_surface.html)

---

## AWS 컴퓨트 리소스 생성 

1. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/pre-condition-0.png](./static/mobilize/iac/compute/pre-condition-0.png?classes=lab_picture_small)

2. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/pre-condition-1.png](./static/mobilize/iac/compute/pre-condition-1.png?classes=lab_picture_small)

3. terraform plan 과정에서 에러가 발생합니다. 이는 프로비져닝하려는 AMI ID와 CPU Architecture가 보안팀의 보안 요구사항에 부합하지 않는 프로비져닝를 시도했기때문 입니다.

![Images/pre-condition-2.png](./static/mobilize/iac/compute/pre-condition-2.png?classes=lab_picture_small)

4. ami_id 값은 사내 보안팀이 검증한 이미지 `ami-0c1f7b7eb05c17ca5` 여야 합니다. **Variable** 메뉴로 이동하여 **Edit variable**을 선택후 사전에 승인된 ami_id로 변경 합니다.

![Images/pre-condition-3.png](./static/mobilize/iac/compute/pre-condition-3.png?classes=lab_picture_small)


> AWS Workshop Studio에서는 Marketplace 의 이미지를 지원하지 않습니다. 따라서, Center for Internet Security(CSI)의 AMI ID 대신 특정 ARM의 AMI ID를 사용하여 Hardened AMI를 사용하는 시나리오를 재연합니다.


1. `ami-0c1f7b7eb05c17ca5` 로 변경후, **Save variable** 클릭해 저장하세요. 왼쪽 메뉴바에서 **New run**을 누른 후, 다시 **Start**를 클릭하세요.

```bash
ami-0c1f7b7eb05c17ca5
```

![Images/pre-condition-4.png](./static/mobilize/iac/compute/pre-condition-4.png?classes=lab_picture_small)

1. Terraform Plan 이 이번에는 정상적으로 작동함을 볼 수 있습니다. 승인된 이미지 그리고 승인된 인스턴스 타입만이 Terraform Plan을 성공적으로 마칠 수 있기에 보안 요구사항을 Shift Left한 결과를 의미합니다. 참고로 인스턴스의 예상 비용도 확인할 수 있습니다. 프로비져닝를 위해 **Confirm & apply**를 선택하세요.

![Images/pre-condition-5.png](./static/mobilize/iac/compute/pre-condition-5.png?classes=lab_picture_small)

7. Comment 추가후, **Comfirm plan** 을 클릭하세요. 

![Images/pre-condition-6.png](./static/mobilize/iac/compute/pre-condition-6.png?classes=lab_picture_small)

8. [AWS EC2 console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances)에서 `GravitonServerWithAmazonLinux2023`라는 새로운 EC2 Instance 가 프로비져닝되었음을 확인할 수 있습니다. 

![Images/pre-condition-7.png](./static/mobilize/iac/compute/pre-condition-7.png?classes=lab_picture_small)


## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/1_pre-condition-ec2)에서도 보실 수 있습니다.

모빌라이즈 단계에서 EC2 인스턴스를 프로비져닝시 조직 혹 인더스트리의 Compliance를 만족하는 특정 Hardened AMI(Amazon Machine Image) 그리고 특정 인스턴스 타입 혹 CPU 아키텍쳐만 프로비져닝를 할 수 있습니다.

### main.tf

```ruby
data "aws_ami" "al2023_arm" {
  most_recent = true

  owners = ["amazon"]
  
  filter {
    name = "image-id"
    values = var.ami_id
    # ami-0c031a79ffb01a803는 사용자가 프로비져닝하려는 x86_64 이미지
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
```

### vars.tf


```ruby
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
  description = "보안 팀이 승인한 AMI만 사용"
}

variable ami_name_filter {
  type = string
  default = "*al2023*-arm64"
  # default = "*al2023*-x86_64"
  description = "보안 팀이 승인한 Amazon Linux 2023 AMI ARM64 지원 AMI"
}
```


> 컴퓨트 리소스의 attack surface 최소화하기 위해 보안팀과 조직의 컴플라이언스에 부합하는 이미지를 사용해서 성공적으로 EC2 Instance 를 프로비져닝하였습니다. 다음 실습을 위해 **Next**를 선택해 주세요.
