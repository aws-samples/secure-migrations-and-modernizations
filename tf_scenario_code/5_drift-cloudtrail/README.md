---
title: "로그 파일 무결성 검증 활성화"
weight: 30
---
## 아키텍쳐 오버뷰

![architecture-5.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/architecture/architecture-5.png?raw=true)

## AWS 모범사례
* [MIG-SEC-BP-13.1 이벤트 탐지 및 조사를 위한 AWS 서비스 기능 이해하기](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-sec.html#mig-sec-bp-13.1-understand-capabilities-for-event-detection-and-investigation)
* LM.9 Have you implemented controls to avoid configurational changes to CloudTrail?

## 로그 파일 무결성 검증
[CloutTrail](https://docs.aws.amazon.com/ko_kr/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)
CloudTrail은 사용자의 AWS 계정 내에서 이루어지는 모든 API 호출 기록을 기록하고 모니터링할 수 있는 기능을 제공합니다.
이번 장에서는 CloudTrail의 로그 파일 무결성 검증 설정을 고의적으로 변경했을 때 Drift detection을 통해 이를 감지하고 복구하는 과정을 실습합니다.
로그 파일 무결성 검증은 CloudTrail이 로그 파일을 전송한 후 해당 파일이 수정, 삭제 또는 변경되지 않았는지 확인하기 위해 CloudTrail 로그 파일 무결성 검증을 사용할 수 있습니다.

## Workshop 선택하기
**Projects & workspaces**  에서 `5_Drift_Cloudtrail`를 선택합니다
![3_3_0_select_workshop.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_0_select_workshop.png?raw=true)

## CloudTrail 생성하기
1. Hashicorp 워크샵의 `New run` 버튼을 눌러 Trail을 생성합니다. (Terraform IaC 프로비져닝)
![3_3_0_new_run.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_0_new_run.png?raw=true)
2. [CloudTrail 콘솔](https://ap-northeast-2.console.aws.amazon.com/cloudtrailv2/home?region=ap-northeast-2#/)로 이동하여 생성된 Trail을 선택한 후 Log file validation 활성화  여부를 확인합니다. (Trail name: `cloudtrail` )
![3_3_1_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_1_cloudtrail.png?raw=true)

## Trail의 로그 파일 무결성 검증 비활성화 하기
의도적으로 로그 파일 무결성 검증을 비활성화 합니다.
1. [CloudTrail 콘솔]((https://ap-northeast-2.console.aws.amazon.com/cloudtrailv2/home?region=ap-northeast-2#/))로 이동하여 `cloudtrail` Trail의 을 선택 후 `Edit` 버튼을 클릭합니다.
![3_3_2_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_2_cloudtrail.png?raw=true)
2. Log file validation 기능을 비활성화 시킨 후 `Save changes` 버튼을 클릭합니다.
![3_3_3_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_3_cloudtrail.png?raw=true)


## 변경 감지 확인 및 복구
> Drift Detection 에서 자동으로 감지하나 **Start health assessment**를 클릭하여 대기 시간을 최소화하며 워크샵을 진행해주세요.

1. Hashicorp 워크스페이스의 Health 페이지에서 Drift 감지(Unhealhty)를 확인합니다.
![3_3_4_drift_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_4_drift_cloudtrail.png?raw=true)
2. 복구를 실행합니다.
![3_3_5_recover_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_5_recover_cloudtrail.png?raw=true)
![3_3_6_recover_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_6_recover_cloudtrail.png?raw=true)
3. [CloudTrail 콘솔]((https://ap-northeast-2.console.aws.amazon.com/cloudtrailv2/home?region=ap-northeast-2#/))로 이동하여 생성된 Trail을 선택한 후 Log file validation 활성화  여부를 확인합니다. (Trail name: `cloudtrail` )
![3_3_1_cloudtrail.png](https://github.com/kr-partner/aws-partner-summit-docs/blob/main/static/images/3/3/3_3_1_cloudtrail.png?raw=true)

---
## Terraform IaC(Infrastructure as Code)

> 모든 AWS 리소스 프로비져닝는 Terraform Enterprise 에서 합니다. 아래의 코드는 Terraform Enterprise 에서 연결된 [github](https://github.com/aws-samples/secure-migrations-and-modernizations/tree/main/tf_scenario_code/5_drift-cloudtrail)에서도 보실 수 있습니다.

### main.tf

```ruby
resource "random_id" "bucket-suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail-logs" {
  bucket        = "cloudtrail-logs-${random_id.bucket-suffix.hex}"
  force_destroy = true
}

resource "aws_cloudtrail" "cloudtrail" {
  depends_on = [aws_s3_bucket_policy.bucket-policy]

  name                          = "cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail-logs.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  enable_log_file_validation = true
}

data "aws_iam_policy_document" "policy-doc" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail-logs.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/cloudtrail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail-logs.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/cloudtrail"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.cloudtrail-logs.id
  policy = data.aws_iam_policy_document.policy-doc.json
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
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

### vars.tf

```ruby
variable "region" {
  type = string
  default = "ap-northeast-2"
}
```

> Continuous Validation 워크샵을 시작합니다. **Next**를 클릭해주세요.