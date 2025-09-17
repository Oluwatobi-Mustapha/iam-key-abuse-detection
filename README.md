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

---

## Architecture  

```bash
├── management-account/    # Org root (billing only)
│   └── main.tf
├── security-account/      # Detection & response logic
│   ├── main.tf
│   ├── lambda.tf
│   └── variables.tf
├── workload-account/      # Attack simulation + CloudTrail setup
│   └── main.tf






