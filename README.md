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
```

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
```

## Step 2: Forward IAM Activity from Workload Account to Security Bus

In this step, we configure the workload account (Workload2) to forward IAM activity events to the central EventBridge bus (`org-security-bus`) in the security account.

### Terraform Code (`terraform/workload/main.tf`)
```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "Workload2"
}

# EventBridge rule that matches IAM events
resource "aws_cloudwatch_event_rule" "iam_activity" {
  name        = "iam-activity-forward"
  description = "Forward IAM activity to org-security-bus"
  event_pattern = <<EOF
{
  "source": ["aws.iam"]
}
EOF

  tags = {
    Project     = "CloudSOC"
    Environment = "workload2"
    ManagedBy   = "Terraform"
  }
}

# IAM role that EventBridge assumes to put events on the central bus
resource "aws_iam_role" "eventbridge_to_security" {
  name = "EventBridgeToSecurityRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project     = "CloudSOC"
    Environment = "workload2"
    ManagedBy   = "Terraform"
  }
}

# IAM policy for EventBridge to forward events
resource "aws_iam_role_policy" "eventbridge_to_security_policy" {
  name = "EventBridgeToSecurityPolicy"
  role = aws_iam_role.eventbridge_to_security.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "events:PutEvents"
        Resource = "arn:aws:events:us-east-1:222964727827:event-bus/org-security-bus"
      }
    ]
  })
}

# Target that sends IAM activity events to the security bus
resource "aws_cloudwatch_event_target" "forward_to_security" {
  rule           = aws_cloudwatch_event_rule.iam_activity.name
  arn            = "arn:aws:events:us-east-1:222964727827:event-bus/org-security-bus"
  event_bus_name = "default"
  target_id      = "to-security"
  role_arn       = aws_iam_role.eventbridge_to_security.arn
}
```

### Apply Terraform
```bash
cd terraform/workload
terraform init
terraform plan
terraform apply
```
