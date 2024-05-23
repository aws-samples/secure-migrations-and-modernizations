---
title: "컴퓨트 리소스의 attack surface 최소화"
weight: 21
---

## 아키텍쳐 오버뷰

![architecture-1.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-1.png?raw=true)

## 마이그레이션 보안 요구사항(MSR) - Infrastructure Protection 
* MSR.IP.1 - 마이그레이션 전후에 취약성 평가를 수행했나요?

모빌라이즈 단계에서부터 AWS 에서 사용 할 운영 체제를 강화하고 사용 중인 구성 요소와 외부 서비스를 최소화하여 의도하지 않은 액세스에 대한 노출을 최소화합니다. Amazon EC2의 경우, 패치를 적용한 Hardened AMI(Amazon Machine Image)를 생성할 수 있습니다. 이는 조직의 특정 보안 요구 사항을 충족할 수 있으며 인더스트리의 컴플라이언스를 만족하는 이미지를 사용해야하는 경우도 있습니다. 

AMI에 적용하는 패치 및 기타 보안 제어 조치는 생성 시점에 발효되며 시작한 후 AWS Systems Manager 등을 사용하여 수정하지 않는 이상 동적으로 변경되지 않습니다. 예를 들면, [Center for Internet Security(CSI)](https://aws.amazon.com/marketplace/seller-profile?id=dfa1e6a8-0b7b-4d35-a59c-ce272caee4fc&ref=dtl_B07M68CJS5)에서 시작하고 반복하면 됩니다.

AWS는 취약성 관리 프로그램에 도움이 되는 다양한 서비스를 제공합니다. Amazon Inspector는 AWS 워크로드에서 소프트웨어 문제와 의도하지 않은 네트워크 액세스를 지속적으로 검사합니다. AWS Systems Manager는 Amazon EC2 인스턴스 전반의 패치 관리를 지원합니다.

## AWS 모범사례
* [MIG-SEC-BP-2.1 모빌라이즈시 사용할 도구(tool)들을 매핑 수행](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/assess-sec.html#mig-sec-bp-2.1-perform-a-tools-mapping-exercise)
* [SEC06-BP02 공격 표면 축소](https://docs.aws.amazon.com/ko_kr/wellarchitected/latest/security-pillar/sec_protect_compute_reduce_surface.html)

---

Terraform Workspace 환경의 `1_pre-condition-ec2` 워크스페이스에서 시작합니다.

![image-20240514084730666](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514084730666.png)

## AWS 컴퓨트 리소스 생성 

1. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/pre-condition-0.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513204913352.png)

2. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/pre-condition-1.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513205046692.png)

3. terraform plan 과정에서 에러가 발생합니다.
  - FinOps 측면에서 AWS의 신규 인스턴스 타입들을 대상으로 지정할 수 있습니다.
  - 시나리오 상 보안팀의 요구사항으로 보안 측면에서 아직 ARM CPU 아키텍처에 대한 검증이 완료되지 않았으므로 AMD64(x86_64)의 OS 타입의 이미지를 사용 해야 합니다.

![Images/pre-condition-2.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513205446207.png)

4. terraform plan 과정의 안내에 따라 **Variable** 메뉴로 이동하여 **Edit variable**을 선택후 사전에 승인된 값으로 변경 합니다. `instance_type`은 `t3.micro`, `t3.large`, `m6i.midium`, `m6i.large` 중 하나를 기입합니다.

![Images/pre-condition-3.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513210258369.png)

![Images/pre-condition-4.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513210409180.png)

변경 후 **Save variable** 클릭해 저장하세요.

5. 다음으로 terraform plan 과정의 안내에 따라 `ami_type`을 `arm64`에서 `amd64`로 변경합니다.

![Images/pre-condition-5.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513210615164.png)

![Images/pre-condition-6.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513210706209.png)

변경 후 **Save variable** 클릭해 저장하세요.

5. 우측 상단의 **New run**을 누른 후, 다시 **Start**를 클릭하세요.

![Images/pre-condition-7.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513210850330.png)

6. Terraform Plan 이 이번에는 정상적으로 작동함을 볼 수 있습니다. 승인된 CPU 아키텍처와 허용된 이미지, 그리고 승인된 인스턴스 타입만이 Terraform Plan을 성공적으로 마칠 수 있기에 보안 요구사항을 Shift Left한 결과를 의미합니다. 참고로 인스턴스의 예상 비용도 확인할 수 있습니다. 프로비져닝를 위해 **Confirm & apply**를 선택하세요.

![Images/pre-condition-8.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513211259860.png)

7. Comment 추가후, **Comfirm plan** 을 클릭하세요. 

![Images/pre-condition-9.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513211453984.png)

8. [AWS EC2 console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances)에서 `Ubuntu_22.04`라는 새로운 EC2 Instance 가 프로비져닝되었음을 확인할 수 있습니다. 

![Images/pre-condition-10.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/Monosnap%20Image%202024-05-13%2021-18-30.png)


## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/1_pre-condition-ec2)에서도 보실 수 있습니다.

모빌라이즈 단계에서 EC2 인스턴스를 프로비져닝시 조직 혹 인더스트리의 Compliance를 만족하는 특정 Hardened AMI(Amazon Machine Image) 그리고 특정 인스턴스 타입 혹 CPU 아키텍쳐만 프로비져닝를 할 수 있습니다.

### main.tf

```hcl
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
```

### variables.tf

```ruby
variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "instance_type" {
  type    = string
  default = "m5.large"
}

variable "ami_type" {
  type        = string
  default     = "arm64"
  description = "amd64 or arm64"
}
```

## Postcondigion

`precondion`은 해당 리소스가 생성 되기 전에 검증하므로, 조건이 만족하지 않는 경우 생성 이전에 실패하게 됩니다. 예제에서는 Plan 단계에서 이미 파악할 수 있는 `variable`로 조건을 설정하였으므로, Plan 단계에서 에러가 발생합니다.
Terraform에는 지정하지 않는 경우, 또는 생성 시 할당되는 리소스의 설정 값이 있는 경우 리소스는 생성되었지만 다음 단계로는 진행되지 않도록 구성하는 `postcondigion`이 있습니다.

1. GitHub에서 `1_pre-condition-ec2/main.tf` 파일을 선택하고 `Edit file` 항목에서 `Edit in place`를 클릭합니다.

![Images/pre-condition-11.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513214753088.png)

기존 `main.tf`에 `postcondition`가 정의 된 다음의 코드를 추가하여 저장합니다. 

```hcl
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
```

2. 기존 코드 아래 추가 후 우측 상단의 `Commit changes...`를 클릭합니다.

![Images/pre-condition-12.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513215123670.png)

3. `Commit changes` 모달에서 메지시 확인 후 `Commit changes` 버튼을 클릭합니다.

![Images/pre-condition-13.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/2024-05-13%2021-52-13.png)

4. Terraform Workspace에 연결된 VCS 코드에 변경이 발생하였으므로 자동으로 Run이 실행됩니다. `Last run` 박스에서 `See details` 버튼을 클릭하여 Plan 상태를 확인하러 이동합니다.

![Images/pre-condition-14.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513215419945.png)

5. Plan에 이상이 없음을 확인합니다. 하단의 `Confirm & apply`를 클릭하고, 이전처럼 메시지 입력 후 `Confirm plan` 버튼을 클릭합니다.

![Images/pre-condition-15.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513215652896.png)

6. Apply 단계에서 에러가 발생함을 확인합니다.

![Images/pre-condition-16.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513215752290.png)

7. [AWS EC2 console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances)에서 `Ubuntu_22.04_PostCondition`라는 새로운 EC2 Instance 가 프로비져닝되었음을 확인할 수 있습니다. 하지만 Terraform에서는 생성 후 `postcondition`을 만족하지 못하여 에러가 발생하고 중단됩니다.

![Images/pre-condition-17.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/2024-05-13%2022-00-10.png)

8. `postcondition`을 만족하기 위해 GitHub에서 `root_block_device`의 `encrypted = true` 옵션을 추가하고 다시 `Commit changes`를 수행합니다.

```hcl
### 기존 코드 생략 ###

resource "aws_instance" "ec2_postcondition" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = var.instance_type
  associate_public_ip_address = true

  root_block_device {
    encrypted = true
  }

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
```

![Images/pre-condition-18.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513220338653.png)

9. 코드 변경 후 다시 프로비저닝 되는 Run을 확인하고 `Confirm plan`을 수행하여 생성 후 정상적으로 성공한 프로비저닝 결과를 관찰합니다.

![Images/pre-condition-19.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240513220849937.png)

> 컴퓨트 리소스의 attack surface 최소화하기 위해 보안팀과 조직의 컴플라이언스에 부합하는 이미지를 사용해서 성공적으로 EC2 Instance 를 프로비져닝하였습니다. 다음 실습을 위해 **Next**를 선택해 주세요.
