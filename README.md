# tf-aws-infra

- [tf-aws-infra](#tf-aws-infra)
  - [Prerequisites](#prerequisites)
    - [AWS CLI Setup](#aws-cli-setup)
  - [Setting Custom Variables](#setting-custom-variables)
  - [Usage](#usage)

## Prerequisites

> Before deploying the Terraform configuration, ensure that the following prerequisites are met:

- **Terraform**: Install Terraform version 0.14 or higher.
- **AWS CLI**: Install and configure the AWS CLI with appropriate permissions.
- **AWS Account**: Ensure you have access to an AWS account with permissions to create networking resources (VPCs, subnets, route tables, internet gateways, etc.).
- **Access to AWS environment variables**: Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables for authentication with AWS. Alternatively, you can configure a profile using aws configure.

### AWS CLI Setup
```
aws configure --profile profile_name
```

## Setting Custom Variables

> To customize the VPC, subnets, and other resource configurations, create a `terraform_file.tfvars` file or pass variables directly through the command line. Example:

```
vpc_cidr = "10.0.0.0/16"
public_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
```

## Usage

> To apply the Terraform configurations and provision the resources:

1.	Initialize Terraform: This step downloads the necessary provider plugins.
```
cd src/terraform
terraform init
```
2.	Preview the infrastructure changes: This will show you the resources that will be created, modified, or destroyed.
```
export AWS_PROFILE=profile_name
terraform plan -var-file="terraform_file.tfvars"
```
3.	Apply the configuration: This command creates the networking resources in AWS. Pass the -var-file flag to provide a custom terraform.tfvars file:
```
terraform apply -var-file="terraform_file.tfvars"
```
4.	Destroy resources: When you’re done and wish to clean up the resources, use the destroy command.
```
terraform destroy -var-file="terraform_file.tfvars"
```
