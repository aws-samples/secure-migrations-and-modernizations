---
title: "S3 ACL 비활성화 및 퍼블릭 액세스 제어"
weight: 23
---
## 아키텍쳐 오버뷰

![architecture-3.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-3.png?raw=true)

## 마이그레이션 보안 요구사항(MSR) - Data Protection / Infrastructure Protection 
* MSR.DP.3 - 버킷 수준에서 'S3 블록 공개 액세스' 설정을 활성화하셨나요??

S3 버킷 수준에서 퍼블릭 액세스 차단은 오븥젝트가 퍼블릭 액세스 권한을 갖지 않도록 하는 제어 기능을 제공합니다. 퍼블릭 액세스는 ACL(액세스 제어 목록), 버킷 정책 또는 둘 다를 통해 버킷과 오브젝트에 부여됩니다. Amazon S3의 최신 사용 사례 대부분은 더 이상 ACL을 사용할 필요가 없습니다. 각 객체에 대해 액세스를 개별적으로 제어할 필요가 있는 드문 상황을 제외하고는 ACL을 비활성화한 채로 두는 것이 좋습니다. ACL을 비활성화하면 누가 객체를 버킷에 업로드했는지에 관계없이 정책을 사용하여 버킷의 모든 객체에 대한 액세스를 제어할 수 있습니다. 자세한 내용은 객체 소유권 제어 및 버킷에 대해 [ACL 사용 중지 단원](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/about-object-ownership.html)을 참조하십시오.

* MSR.IP.13 - S3 버킷에 대한 공개 읽기 및 쓰기 액세스를 금지했나요??

데이터의 무결성과 보안을 보장하기 위해서 Amazon Simple Storage Service (Amazon S3) 버킷에 공개적으로 액세스할 수 없도록 하여 AWS 클라우드의 리소스에 대한 액세스를 관리합니다. 이 규칙은 공개 액세스를 방지하여 권한이 없는 원격 사용자로부터 민감한 데이터를 안전하게 보호하는 데 도움이 됩니다. 


## AWS 모범사례

* [MIG-SEC-BP-7.1 데이터 보호를 위한 보안 제어 설정](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/mobilize-sec.html#mig-sec-bp-7.1-establish-security-controls-for-protecting-data-at-rest)
* [SEC05-BP02 모든 계층에서 트래픽 제어](https://docs.aws.amazon.com/ko_kr/wellarchitected/latest/security-pillar/sec_network_protection_layered.html)

---

## ACL이 비활성화된 S3만 프로비져닝

1. **Projects & workspaces** 에서 `3_Sentinel_s3`를 선택합니다

![Images/s3-0.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-0.png?raw=true)

2. 상단 오른쪽의 **New run** 버튼을 누르면 위에 공유된 Terraform IaC의 프로비져닝를 시도합니다. 

![Images/s3-1.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-1.png?raw=true)

3. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/s3-2.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-2.png?raw=true)

4. 이번에는 MSR의 조건이 [Sentinel Policy](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/275a171d230d22ca38294696f22ae3c4fdf4c890/tf_sentinel_code/sentinel-policy-s3/terraform-restrict-s3.sentinel#L75) 로 정의가 되어 있기에 `terraform plan`은 성공했지만 `Sentinel policies`에서 실패합니다. 이는 Sentinel Policy에서 security groups의 cidr이 `0.0.0.0/0` 정의된 경우, 프로비져닝가 진행되지 않고 종료가 됩니다. ACL이 enable된 경우, 프로비져닝가 진행되지 않고 종료가 됩니다. [Enforcement mode](https://github.com/aws-samples/secure-migrations-and-modernizations/blob/main/tf_sentinel_code/sentinel-policy-s3/terraform-restrict-s3.sentinel)는 반드시 만족해야하는 **hard-mandatory**로 정의되어 있습니다. 

> [Sentinel](https://developer.hashicorp.com/sentinel/docs/concepts/policy-as-code)의 Policy as Code 그리고 Enforcement Levels는 [여기](https://developer.hashicorp.com/sentinel/docs/concepts/enforcement-levels)를 참조해주세요.

![Images/s3-3.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-3.png?raw=true)

5. **Variable** 메뉴로 이동해서 **Edit variable**을 선택후, **acl_disabled** 값을 해당 `true` 로 변경함으로써, main.tf의 조건문에서 `acl    = var.acl_disabled ? "private" : "public-read"` 에서 **private**을 설정하게 됩니다.

![Images/s3-condition.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-condition.png?raw=true)

> Conditional Expressions은 [여기](https://developer.hashicorp.com/terraform/language/expressions/conditionals)를 참조해주세요. [Amazon S3의 보안 모범 사례](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/security-best-practices.html#security-best-practices-detect)와 같이 ACL을 비활성화하고 버킷 내 모든 객체의 소유권을 얻으려면 S3 객체 소유권에 버킷 소유자 적용 설정을 적용하세요.

![Images/s3-4.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-4.png?raw=true)

6. **Save variable** 클릭해 저장하세요. 

![Images/s3-5.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-5.png?raw=true)

7. 왼쪽 메뉴바에서 **New run**을 누른 후, 다시 **Start**를 클릭하세요.

![Images/s3-6.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-6.png?raw=true)

8. terraform plan을 실행하기 위해 **Start** 버튼을 클릭해주세요.

![Images/s3-7.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-7.png?raw=true)

9. Terraform Plan 과 Sentinel policies가 이번에는 정상적으로 패스했음을 볼 수 있습니다. 프로비져닝를 위해 **Confirm & apply**를 선택하세요.

![Images/s3-8.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-8.png?raw=true)

10.  Comment 추가후, **Comfirm plan** 을 클릭하세요. 

![Images/s3-9.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-9.png?raw=true)

11.  [Amazon S3 console](https://ap-northeast-2.console.aws.amazon.com/s3/home?region=ap-northeast-2)에서 `s3-bucket-sentinel-`id 라는 새로운 S3 버킷이 되어있음을 확인 할 수 있습니다. 

![Images/s3-10.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-10.png?raw=true)

12.  **Permissions** tab을 선택한 후, 버킷 액세스 및 ACL이 퍼블릭 액세스가 비활성화되어 있음을 확인할 수 있습니다. 

![Images/s3-11.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-11.png?raw=true)

![Images/s3-12.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/mobilize/iac/s3/s3-12.png?raw=true)

## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/3_sentinel-s3)에서도 보실 수 있습니다.

모빌라이즈 단계에서부터 어떤 데이터가 민감한 데이터, 기밀 데이터 또는 공개 데이터인지 파악하세요. ACL을 비활성화하면 누가 객체를 버킷에 업로드했는지에 관계없이 정책을 사용하여 버킷의 모든 객체에 대한 액세스를 보다 쉽게 제어할 수 있습니다.

### main.tf

```ruby
resource "random_id" "bucket-suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "s3-bucket-sentinel" {
  bucket = "s3-bucket-sentinel-${random_id.bucket-suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "s3-bucket-ownership" {
  bucket = aws_s3_bucket.s3-bucket-sentinel.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3-bucket-ownership]

  bucket = aws_s3_bucket.s3-bucket-sentinel.id
  acl    = var.acl_disabled ? "private" : "public-read"
}
```

### vars.tf

```ruby
variable "acl_disabled" {
  type    = bool
  default = false # ACL을 비활성화하려면 true로 설정하세요
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}
```

> ACL이 활성화되는 버킷을 사전에 방지하고 버킷에 공개적으로 액세스할 수 없도록 제한된 S3 버킷을 프로비져닝하였습니다. 다음 실습을 위해서 **Next**를 클릭해 주세요.

