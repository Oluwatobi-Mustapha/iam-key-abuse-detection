# How I Automated Detection & Response for IAM Key Abuse  

**(Terraform + Python + Lambda + Slack)**  

## Overview  

IAM access keys are critical for AWS operations but are vulnerable to abuse if compromised. Detecting unusual activity and responding quickly is essential.  

This project demonstrates an automated system for detecting and responding to IAM key abuse across AWS accounts using **Terraform, Python, AWS Lambda, and Slack**.  

The setup follows AWS best practices by using a **multi-account AWS Organization**:  

- **Management Account** → Billing + Org management (default).  
- **Security Account** → Hosts the detection Lambda + cross-account roles.  
- **Workload Account** → Simulates attacker activity + provides CloudTrail logs.  

---

## Prerequisites  

- AWS Organization with at least **3 accounts** (Management, Security, Workload)  
- Cross-account IAM roles configured (Security → Workload log access)  
- Terraform installed (≥ v1.5)  
- AWS CLI configured for each account  

**Management Account → Default account created when enabling AWS Organizations.**

**Security Account → Runs the Lambda detection engine.**

**Workload Account → Used to simulate attacker activity and generate CloudTrail logs.**

## Step 0: Slack + Lambda Integration 

- Created Slack channel: #aws-incidents

- Configured Incoming Webhook (stored in AWS Secrets Manager)

- Deployed test Lambda function to send alerts → Slack

- Mock CloudTrail events tested successfully ✅

## Next Steps

Implement IAM key abuse detection logic in Lambda

Automate infrastructure with Terraform across accounts

Expand alerts to multi-account environments


---


## Step 1: Security Account Setup

Inside `terraform/security/main.tf`, we defined the central EventBridge bus for cross-account IAM event forwarding.

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "security"
}

resource "aws_cloudwatch_event_bus" "central_bus" {
  name = "org-security-bus"
}

Allow workload accounts to put events

resource "aws_cloudwatch_event_permission" "org_accounts" {
  principal       = "*"
  action          = "events:PutEvents"
  event_bus_name  = aws_cloudwatch_event_bus.central_bus.name
  statement_id    = "AllowWorkloadAccounts"
}


To deploy:
cd terraform/security
terraform init
terraform plan
terraform apply


**Architecture**  

```bash
├── management-account/    # Org root (billing only)
│   └── main.tf
├── security-account/      # Detection & response logic
│   ├── main.tf
│   ├── lambda.tf
│   └── variables.tf
├── workload-account/      # Attack simulation + CloudTrail setup
│   └── main.tf











