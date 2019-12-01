# Example - terraform configurations managed by infrastracture team

* Organization manages infrastracture as terraform based code
* There is an infrastructure team which actually maintains the system and develops terroform code-base along with production|dev|staging|test-1,2,3 environments
* There is also security team which needs to maintain security related subset of the infrastructiure like aws security groups, iam policies, s3 bucket policies, etc

## The problem: 
Security Team needs some simple way to manage only assets they are responsible on.  
So running `terraform apply ` for all the infrastracture after adding one string into security group rule is not acceptable

## Solution design:
* Security team maintains their assets in separate repo and terraform states - https://github.com/kosta709/terraform-security-team-repo-example
* Terraform configurations in the security repo should apply on security assets only
* Operations for maintaining security assets with terraform should be clear and simple - operator needs to change values only and apply the changes by commit/push assuming that CI/CD system will run terraform. 

## This Demo
* [./tf](tf) - terraform code-base for vpc and main-service (aws auto sclaling group instances behind ELB) 

* [configurations/vpc/<environment-name>](configurations/vpc/dev) terraform backend definition and tfvars for vpc

* [configurations/main-service/<environment-name>](configurations/main-service/dev) terraform backend definition and tfvars for vpc


*Note:* main.tf and vars.tf are symlinks for the appropriative files in main-service-infra/ folder. Such method helps to avoid extra copy/paste for each environment. For additional customization posiibilities see https://www.terraform.io/docs/configuration/override.html 

* [security-team-repo](https://github.com/kosta709/terraform-security-team-repo-example)

## Run it
0. Create or reference VPC
This step is optional, you can reference existing vpc and subnet
```
cd terraform-infra-team-repo-example/configurations/vpc/<env-name>
terraform init|plan|apply
```

1. Clone https://github.com/kosta709/terraform-security-team-repo-example and create or update security groups
set varibales in `configurations/main-service/<env-name>/`

```
cd terraform-security-team-repo-example/configurations/main-service/<env-name>
terraform init|plan|apply
```

2. Run main-service-infra

set varibales in [configurations/main-service/env-name](configurations/main-service/dev/terraform.tfvars)  : vpc_tags_selector, public_subnet_names, private_subnet_names  

In this example it is already set to created vpc in step 0

```
cd terraform-infra-team-repo-example/configurations/main-service/<env-name>

terraform init|plan|apply
```



