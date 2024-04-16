## AWS Partner Summit Seoul 2024

해당 github repo는 AWS Partner Summit Seoul 2024의 워크샵에서 사용될 예정입니다.  

## Infrastructure as Code(IaC) 활용한 Shift 보안 요구사항 검증 Left 구현

[Infrastructure as Code(IaC) 템플릿을 통한 리소스 프로비저닝](https://docs.aws.amazon.com/wellarchitected/latest/migration-lens/migrate-ops.html#MIG-OPS-bp-9.2-provision-resources-through-infrastructure-as-code-iac-templates)하는 것은 Well-Architected 마이그레이션 렌즈에서 가장 기본적으로 수행되야할 모범 사례 중에 하나입니다. IaC의 장점 중에 하나는 리소스가 프로비져닝 되기 전에 리소스에 대한 구성 정보를 사전에 파악할 수 있고 이를 토대로 마이그레이션 보안 요구사항을 충족하는지 프로비져닝 전에 검증할 수 있다는 것 입니다. IaC로는 [AWS CloudFormation](https://docs.aws.amazon.com/ko_kr/AWSCloudFormation/latest/UserGuide/Welcome.html), [AWS CDK](https://docs.aws.amazon.com/ko_kr/cdk/v2/guide/getting_started.html), [Terraform](https://www.terraform.io/), [Ansible](https://www.ansible.com/), [puppet](https://www.puppet.com/), [Pulumi](https://www.pulumi.com/), [OpenTofu](https://opentofu.org/) 등 다양한 옵션이 존재합니다. 오늘 워크샵에서는 AWS 리소스 배포 전/후 지속적으로 보안 거버넌스를 유지하기 위해 아래 3가지 HashiCorp의 Terraform 솔루션을 활용합니다. 

### Shift 보안 요구사항 검증 Left 구현**
* 마이그레이션 보안 요구사항(MSR) 의 Policy as code화를 통해 리소스 배포 전 보안 요구사항 구현 여부를 검증
* 배포 후 지속적인 인프라 구성 상태 감지 및 정책 위반시 원복
* 운영 중 OS, 서비스 구성, 애플리케이션 상태 감지 및 알람


### HashiCorp의 Terraform 솔루션
* [Terraform Sentinel](https://developer.hashicorp.com/sentinel)을 활용한 마이그레이션 보안 요구사항(MSR) 의 Policy as code
* [Drift detection](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/health#drift-detection)를 활용해 프로비져닝 된 AWS 리소스의 보안 거버넌스 유지
* [Continuous validation](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/health#continuous-validation)를 활용해 운영 중인 OS, 서비스 구성, 애플리케이션의 보안 거버넌스

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

