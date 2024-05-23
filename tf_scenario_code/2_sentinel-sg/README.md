---
title: "네트워크 트래픽 제어"
weight: 22
---
## 아키텍쳐 오버뷰

![architecture-2.png](/static/architecture/architecture-2.png?classes=lab_picture_small)

## 마이그레이션 보안 요구사항(MSR) - Infrastructure Protection 
* MSR.IP.13 - security groups은 승인된 CIDR/포트에 대해서만 트래픽이 허락되도록 구성되어 있나요?

모빌라이즈 단계에서부터 security groups의 규칙은 최소 권한 액세스 원칙을 따라야 합니다. 액세스가 제한되지 않은 경우,(접미사가 /0인 IP 주소)는 해킹, 서비스 거부 공격, 데이터 손실과 같은 악의적인 활동의 기회를 증가시킵니다. 허용되지 않은 포트를 통해 트래픽이 들어오는 경우에도 액세스를 제한해야 합니다.

## AWS 모범사례

* [MIG-SEC-BP-6.2 네트워크 보안 제어 설정](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/mobilize-sec.html#mig-sec-bp-6.2-establish-network-security-controls)
* [MIG-SEC-BP-15.1: 네트워크 리소스 보호](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-sec.html#mig-sec-bp-15.1-protect-your-network-resources)
* [SEC05-BP02 모든 계층에서 트래픽 제어](https://docs.aws.amazon.com/ko_kr/wellarchitected/latest/security-pillar/sec_network_protection_layered.html)


## Terraform Sentinel을 통해 프로비저닝 워크플로우 내에서 MSR의 코드형 정책을 구현하기

Terraform으로 리소스 프로비져닝이 IaC되어 있기에 MSR.IP.13에 대한 정책을 Sentinel Policies로 정의하여 프로비져닝 전에 MSR.IP.13을 만족하는지 검증합니다.  

![Images/sentinel.png](/static/mobilize/iac/network/sentinel.png?classes=lab_picture_small)

::alert[본 워크샵에서는 [Sentinel Policies](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/sentinel)은 사전에 생성되고 적용되어 있습니다. 어떻게 Sentinel Policies를 생성하는지에 대한 실습은 진행하지 않습니다. 본 워크샵에서 사용되는 Sentinel Policies 정책은 [여기](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/main/tf_sentinel_code/sentinel-policy-sg/terraform-restrict-sg.sentinel)를 참조해주세요.]

---

## AWS 컴퓨트 리소스와 security groups 생성 

1. **Projects & workspaces** 에서 `2_Sentinel_sg`를 선택합니다

![Images/sg-0.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514085236540.png)

2. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/sg-1.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514085359970.png)

3. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/sg-2.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514095752377.png)

4. terraform plan은 정상적으로 수행됩니다. 하지만 실행계획을 검토해보면 Security Group의 ingress cidr이 `0.0.0.0/0`으로 모든 IP에 대해 개방되어있습니다.

![image-20240514100610335](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514100610335.png)

5. 보안적으로 모든 IP에 대해 접근을 허용하는 것은 보안적으로 취약하므로 이번 프로비저닝을 취소합니다. 하단의 `Discard run` 버튼을 클릭합니다.

![image-20240514100414711](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514100414711.png)

이번 프로비저닝을 취소하는 사유를 기록하고 `Discard` 버튼을 클릭합니다.

![image-20240514100729077](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514100729077.png)

## security groups 정책 작성

앞서 Attack surface를 최소화 하기위해 사용한 `precondition`기능을 사용하여 Terraform 작성 코드 수준에서 Security Group에 대한 정책을 정의하고, 방어할 수 있습니다. 하지만 모든 사용자가 이같은 규정을 준수하여 코드 작성을 한다는 보장을 기대하기는 어렵습니다.

따라서 Terraform에서는 전반적인 프로비저닝 정책을 정의하고 적용하기위해 Sentinel/OPA 를 활용한 전역 정책을 정의할 수 있습니다.

1. 프로비저닝을 취소한 위 과정에서 Plan을 확인한 UI의 `Download Sentinel Mock` 버튼을 클릭하여 테라폼이 작성한 실행계획을 다운로드 받고 압축을 풀어줍니다.

![image-20240514101300557](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514101300557.png)

2. HashiCorp의 Policy as Code인 Sentinel을 테스트하고 정책을 작성할 수 있는 <https://play.sentinelproject.io> 에 접속합니다. (S3 버킷에 대한 정책 예제가 작성되어 있습니다.)

![image-20240514101300557](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514101547804.png)

3. 우측 `mock-tfplan-v2.sentinel` 탭의 내용을 모두 삭제하고 다운받은 파일들 중 `mock-tfplan-v2.sentinel` 파일을 끌어 해당 영역에 드롭다운 하거나 메모장으로 열어 모든 내용을 복사 후 붙여넣습니다.

![image-20240514102204811](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514102204811.png)

붙여넣은 내용에서 우리가 사용할 실행 계획 상 데이터는 프로비저닝으로 인해 변경사항이 발생 할 `resource_changes`의 내용입니다.

5. 왼쪽의 `policy.sentinel`에 입력할 내용은 다음과 같습니다.

```ruby
import "tfplan/v2" as tfplan

disallowed_cidr_blocks = [
  "0.0.0.0/0",
]

aws_security_groups = filter tfplan.resource_changes as _, resource_changes {
  resource_changes.type is "aws_security_group" and
  	resource_changes.mode is "managed" and
  		(resource_changes.change.actions contains "create" or
      	resource_changes.change.actions is ["update"])
}
  
aws_security_group_ingress_not_allow_all_open = rule {
  all aws_security_groups as _, aws_security_group {
    all aws_security_group.change.after.ingress as ingress {
      all disallowed_cidr_blocks as block {
        ingress.cidr_blocks not contains block
      }
    }
  }
}

main = rule {
  aws_security_group_ingress_not_allow_all_open
}
```

- `import "tfplan/v2" as tfplan`은 Terraform Plan 을 v2 형식으로 읽고, `tfplan` 으로 정의하겠다는 의미 입니다.

- `disallowed_cidr_blocks`은 허용하지 않는 cidr 대역을 지정합니다. 여기서는 `0.0.0.0/0`을 지정하여 ingress 구성에서 모든 IP를 허용하는 값이 설정된 경우에 대해 deny 하기 위해 목록에 추가하였습니다. 해당 값은 List 형식이므로 만약 대역을 세분화 한다면 여기 더 세세하게 지정할 수 있습니다.

- `aws_security_groups`로 시작하는 구문은 실행 계획중 변경되는 리소스 항목의 데이터가 담긴 `resource_changes` 내에서 코드상 정의된 타입 중 `aws_security_group`인 리소스 정보를 담습니다. 세부 조건에 보면 `actions`가 `create`이거나 `update`인 경우로 조건을 부여하여 생성 또는 업데이트 되는 리소스인 경우에 정책에서 탐지하도록 정의하였습니다.

- `aws_security_group_ingress_not_allow_all_open`는 `rule`, 즉, 규칙을 정의합니다. 리소스를 필터링한 `aws_security_groups`의 개별 리소스에서 `ingress`의 `cidr_blocks`이 허용하지 않는 cidr 목록의 값이 없어야 `true`를 반환 합니다.

- `main`은 정책으로 적용되는 실행의 주 함수 입니다. 여기에 다수의 규칙을 설정할 수 있고, 반환은 `true` 또는 `false` 여야 합니다.

5. 오른쪽 하단의 `Run` 버튼을 클릭하여 결과를 확인합니다. `Result: false`가 출력되었으므로 해당 프로비저닝 조건이 실패함을 확인할 수 있습니다.

![image-20240514105136371](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514105136371.png)

6. 조건에 대한 결과만 출력되므로 디버깅을 위해 `print` 구문을 추가해 봅니다.

```ruby
import "tfplan/v2" as tfplan

disallowed_cidr_blocks = [
  "0.0.0.0/0",
]

print("disallowed_cidr_blocks", disallowed_cidr_blocks)

aws_security_groups = filter tfplan.resource_changes as _, resource_changes {
  resource_changes.type is "aws_security_group" and
  	resource_changes.mode is "managed" and
  		(resource_changes.change.actions contains "create" or
      	resource_changes.change.actions is ["update"])
}
  
aws_security_group_ingress_not_allow_all_open = rule {
  all aws_security_groups as _, aws_security_group {
    all aws_security_group.change.after.ingress as ingress {
      all disallowed_cidr_blocks as block {
        print("ingress cidr", ingress.cidr_blocks) and ingress.cidr_blocks not contains block
      }
    }
  }
}

main = rule {
  aws_security_group_ingress_not_allow_all_open
}
```

7. `print`가 추가된 코드를 왼쪽 `policy.sentinel`에 붙여 넣고 다시 오른쪽 하단의 `Run`을 실행하면 허용하지 않는 cidr 내용과 실행 계획상의 ingress cidr이 출력됨을 확인할 수 있습니다.

![image-20240514105504805](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514105504805.png)

## Terraform 정책 적용 - Policy sets

정책은 개별 `Policy`와 이를 그룹핑하고 적용하는 `Policy Set`으로 나뉩니다. 먼저 `2_sentinel-sg` 워크스페이스에 적용할 `Policy Set`을 생성 합니다.

1. 정책은 전역 설정이므로 워크스페이스 목록이 보이는 화면에서 `Settings`를 클릭하여 Organization 설정 화면으로 이동합니다. 다음으로 `Integrations` 부분의 `Policy Sets`로 이동합니다. 새로운 정책을 추가하기 위해 `Connect a new policy set` 버튼을 클릭합니다.

![image-20240514121933253](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514121933253.png)

2. `Connect a policy set` 화면의 첫 단계인 `Connect to VCS`에서 `No VCS connection`을 선택합니다. Policy 또한 VCS로 관리 가능하지만 여기서는 사용자가 Terraform에 직접 구성하는 정책을 사용합니다.

![image-20240514122150032](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514122150032.png)

3. VCS 연결 설정을 하지 않기 때문에 `Configure Settings` 단계로 이동합니다.

![image-20240514122444518](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514122444518.png)

- `Policy framework`는 `Sentinel`을 선택합니다.
- `Name`에 적절한 정책 집합 이름을 정의합니다. 예제에서는 `AWS_MSR_Policy`로 기입하였습니다. (변경 가능)

![image-20240514122846720](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514122846720.png)

- `Scope of policies`에서 해당 정책 그룹이 적용될 범위를 지정합니다. 기본 값인 `Policies enforced globally`가 선택되는 경우 해당 Terraform Organization의 모든 워크스페이스가 영향을 받습니다. 여기서는 `Policies enforced on selected projects and workspaces`를 선택하여 지정한 워크스페이스에서만 규칙이 적용되도록 구성합니다. 지정 완료 후 하단의 `Connect policy set` 버튼을 클릭합니다.

![image-20240514122846720](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514122846720.png)

4. 추가된 정책 집합을 확인합니다. 영향을 받는 프로젝트와 워크스페이스 개수가 표시됩니다.

![image-20240514123158707](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514123158707.png)

## Terraform 정책 적용 - Policy

`Policy Sets`는 규칙의 집합일 뿐 규칙 자체를 정의하지는 않습니다. 따라서 `Policy Set`에 하나 이상의 `Policy`를 지정할 수 있습니다. 앞서 Sentinel Playground에서 검증한 정책 코드를 추가합니다.

1. 정책은 전역 설정이므로 워크스페이스 목록이 보이는 화면에서 `Settings`를 클릭하여 Organization 설정 화면으로 이동합니다. 다음으로 `Integrations` 부분의 `Policies`로 이동합니다. 새로운 정책을 추가하기 위해 `Create a new policy` 버튼을 클릭합니다.

![image-20240514110325477](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514110325477.png)

2. `Create a new policy` 화면에서 다음과 같이 입력합니다.

![image-20240514131313007](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514131313007.png)

- `Policy framework`는 `Sentinel`을 선택합니다.
- `Name`에 적절한 규칙 이름을 정의합니다. 앞서 코드 정의에서 처럼 `aws_security_group_ingress_not_allow_all_open`를 기입합니다.(변경 가능)
- `Description`에는 규칙에 대한 설명을 넣습니다. `이 정책은 Security Group의 Ingress에 보안 제약으로 0.0.0.0/0 을 허용하지 않습니다.`라고 기입합니다.
- `Enforcement behavior`는 규칙의 강도를 정의합니다. 여기서는 강제화 하기 위해 `Hard mandatory`를 선택합니다.

![image-20240514130207256](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514130207256.png)

- `Policy code (Sentinel)`에 Sentinel Playground에서 작성한 코드 내용을 복사하여 붙여넣습니다.
- `Policy Sets`에서 앞서 생성한 정책 집합 이름을 선택합니다. 선택 후 오른쪽의 `Add policy set` 버튼을 클릭하여 해당 정책 집합에 생성한 정책을 할당합니다.
- 설정이 완료되었으면 하단의 `Create Policy` 버튼을 클릭하여 정책 생성을 완료합니다.

3. 추가된 정책을 확인합니다. 몇개의 정책 집합에 대항 정책이 할당되었는지 표시됩니다.

![image-20240514130501818](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514130501818.png)


## 정책 적용된 Terraform Run

1. 다시 **Projects & workspaces** 의 `2_Sentinel_sg` 워크스페이스로 이동합니다.

![Images/sg-0.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514085236540.png)

2. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/sg-1.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514085359970.png)

3. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/sg-2.png](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514095752377.png)

4. 이번에는 MSR의 조건이 [Sentinel Policy](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/275a171d230d22ca38294696f22ae3c4fdf4c890/tf_sentinel_code/sentinel-policy-sg/terraform-restrict-sg.sentinel#L95) 로 정의가 되어 있기에 `terraform plan`은 성공했지만 `Sentinel policies`에서 실패합니다. 이는 Sentinel Policy에서 security groups의 cidr이 `0.0.0.0/0` 정의된 경우, 프로비져닝가 진행되지 않고 종료가 됩니다. [Enforcement mode](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/main/tf_sentinel_code/sentinel-policy-sg/sentinel.hcl)는 반드시 만족해야하는 **hard-mandatory**로 정의되어 있습니다. 

::alert[[Sentinel](https://developer.hashicorp.com/sentinel/docs/concepts/policy-as-code)의 Policy as Code 그리고 Enforcement Levels는 [여기](https://developer.hashicorp.com/sentinel/docs/concepts/enforcement-levels)를 참조해주세요.]

![image-20240514131513684](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514131513684.png)

5. 보안팀의 정책에 따라 Security Group에 특정 IP 대역인 `192.168.0.100/32`를 설정한다고 가정하겠습니다. 따라서, **Variable** 메뉴로 이동해서 **Edit variable**을 선택후, **cidr_blocks** 값을 해당 cidr 로 변경해야 합니다.

![image-20240514132126972](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514132126972.png)

6. `192.168.0.100/32` 로 변경후, **Save variable** 클릭해 저장하세요. 

```bash
192.168.0.100/32
```

![image-20240514132223910](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514132223910.png)

7. 상단 우측의 **New run**을 누른 후, 다시 **Start**를 클릭하세요.

![image-20240514132353697](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514132353697.png)

8. Terraform Plan 이 이번에는 정상적으로 작동함을 볼 수 있습니다. 정책을 만족하는 조건의 구성만 성공적으로 프로비저닝 실행 단계를 실행할 수 있기 때문에 보안 요구사항을 Shift Left한 결과를 의미합니다. 참고로 인스턴스의 예상 비용도 확인할 수 있습니다. 프로비져닝를 위해 **Confirm & apply**를 선택하고 Comment 추가후, **Comfirm plan** 을 클릭하세요. 

![image-20240514132656847](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/image-20240514132656847.png)

10. [AWS EC2 console](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#Instances)에서 `ec2-2_sentinel_sg`라는 새로운 EC2 Instance 가 프로비져닝되었고 security groups의 **inbound rules**는 `192.168.0.100/32`로 설정이 되어있음을 확인 할 수 있습니다. 

![2024-05-14 13-29-19](https://raw.githubusercontent.com/Great-Stone/images/master/picgo/2024-05-14%2013-29-19.png)

## Terraform IaC(Infrastructure as Code)

::alert[모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/2_sentinel-sg)에서도 보실 수 있습니다.]

모빌라이즈 단계에서 EC2 인스턴스를 프로비져닝시 security groups의 cidr 설정이 과대하게 열려있는지 확인하고 보안팀의 정책에 맞는 구성인지 모든 프로비져닝시 지속적으로 validation 해야합니다.

## main.tf

```hcl
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
```

## variables.tf

```hcl
variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cidr_blocks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ec2_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type = list(string)
  # default = ["ami-0c1f7b7eb05c17ca5"]
  default     = ["ami-0c031a79ffb01a803"]
  description = "x86"
}
```

> security groups의 최소 권한 액세스를 Sentinel policy에 정의하여 cidr이 지나치게 관대하게 오픈되는 경우를 사전에 방지합니다. 다음 실습을 위해서 **Next**를 클릭해 주세요.