---
title: "Network 구성 변경"
weight: 30
---
## 아키텍쳐 오버뷰

![architecture-4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-4.png?raw=true)

## AWS 모범사례
* [MIG-SEC-BP-14.1: 사고 대응을 위한 AWS 모범 사례 이해](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-sec.html#mig-sec-bp-14.1-understand-best-practices-for-incident-response)
* [MIG-SEC-BP-15.1: 네트워크 리소스 보호](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-sec.html#mig-sec-bp-15.1-protect-your-network-resources)

## Network 구성 변경
이번 실습에서는 사용자가 임의로 Security Group의 설정을 변경하였을 때 이를 감지하고 복구하는 것을 확인합니다.

## Workflow
실습의 전체적인 workflow는 다음과 같습니다.

![3_2_1_workflow.jpeg](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_1_workflow.jpeg?raw=true)

## Workshop 선택하기
**Projects & workspaces**  에서 `4_Drift_sg`를 선택합니다
![3_2_1_select_workshop.jpeg](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_1_select_workshop.png?raw=true)

## Notification 기능 설정하기
- Workspace에서 이벤트 발생 시 상태를 전달 받기 위해 Notification을 기능을 설정합니다.
![3_2_2_driftdetection-em1.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_2_driftdetection-em1.png?raw=true)
![3_2_3_driftdetection-em2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_3_driftdetection-em2.png?raw=true)

- 이메일을 입력합니다.
![3_2_4_driftdetection-em3.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_4_driftdetection-em3.png?raw=true)
![3_2_5_driftdetection-em4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_5_driftdetection-em4.png?raw=true)

- Email Recipients 에 본인 이메일 정상적으로 추가되었는지 확인 합니다. Run Events 항목에서 Only certain events를 선택하고 `Created`, `Planning`, `Errored` 항목을 선택합니다. Update notification을 클릭 합니다.
![3_2_6_driftdetection-em4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_6_driftdetection-em5.png?raw=true)

## Security Group 설정하기
- Hashicorp 워크샵의 `New run`을 클릭하여 Security Group을 생성합니다. (Terraform IaC 프로비져닝) 이때 Ingress Rule은 0.0.0.0/0의 `80번 포트`를 개방하도록 설정됩니다. 
![3_2_6_1_new_run.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_6_1_new_run.png?raw=true)
- AWS [Security Group 콘솔](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#SecurityGroups:)에서 확인합니다. Security group 이름이 `drift-detection-sg`인 항목을 선택합니다.
![3_2_7_drift1.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_7_drift1.png?raw=true)

- plan 및 apply 동작 시, email로 상태가 공유됩니다.
![3_2_8_driftdetection-em6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_8_driftdetection-em6.png?raw=true)
![3_2_9_driftdetection-em6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_9_driftdetection-em7.png?raw=true)
![3_2_10_driftdetection-em6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_10_driftdetection-em8.png?raw=true)

- Hashicorp 워크스페이스의 Health 페이지에서 **Start health assessment**를 실행하고 현재 Health 상태인 것을 확인합니다.
![3_2_11_drift2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_11_drift2.png?raw=true)
> No drift detected 의미는 AWS Console의 구성정보와 Terraform의 구성정보가 일치함을 의미합니다. 따라서 Health 상태로 간주합니다.
![3_2_12_drif3.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_12_drift3.png?raw=true)

## 포트 번호 변경하기
- AWS [Security Group 콘솔](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#SecurityGroups:)에서 Security group 이름이 `drift-detection-sg`인 항목을 선택한 후 인바운드 포트를 `81`로 변경합니다.
    1. Inbound rules → Edit Inbound rules → Delete (기존 80번 포트 룰 삭제)
    ![3_2_13-1_edit_inbound_rule.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_13-1_edit_inbound_rule.png?raw=true)
    2. Add rule → 81번 포트를 허용하는 신규 룰 설정 
    ![3_2_13-2_edit_inbound_rule.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_13-2_edit_inbound_rule.png?raw=true)
    3. Save 버튼을 클릭하여 저장

## 변경 감지 확인 및 복구
> Drift Detection 에서 자동으로 감지하나 **Start health assessment**를 클릭하여 대기 시간을 최소화하며 워크샵을 진행해주세요.

- Hashicorp 워크스페이스의 Health 페이지에서 Drift 감지(Unhealhty)를 확인합니다.
![3_2_14_drift_detectio_email.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_14_drift_detectio_email.png?raw=true)

- 복구를 실행합니다.
![3_2_15_drift4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/2/3_2_15_drift4.png?raw=true)

- AWS [Security Group 콘솔](https://ap-northeast-2.console.aws.amazon.com/ec2/home?region=ap-northeast-2#SecurityGroups:)에서 인바운드 포트가 `80`으로 복구된 것을 확인합니다.

- Hashicorp 워크스페이스의 Health 페이지에서 Health 상태인 것을 확인합니다.
--- 

## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/4_drift-sg)에서도 보실 수 있습니다.]

### main.tf

```ruby
resource "aws_security_group" "drift-detection-sg" {
  name   = "drift-detection-sg"
  description = "Security group for testing terraform enterprise drift detection"

  ingress {
    from_port   = 80
    to_port     = 80
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

variable "region" {
  type = string
  default = "ap-northeast-2"
}
```


> 로깅 비활성화 시나리오 워크샵을 시작합니다. **Next**를 클릭해주세요.