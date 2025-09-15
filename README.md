# How I Automated Detection & Response for IAM Key Abuse
(Terraform + Python + Lambda + Slack)

## Overview
IAM access keys are critical for AWS operations but are vulnerable to abuse if compromised. Detecting unusual activity and responding quickly is essential.

This project demonstrates an automated system for detecting and responding to IAM key abuse across AWS accounts using Terraform, Python, Lambda, and Slack.

## Step 0: Slack + Lambda Integration
- Slack channel created: `#aws-incidents`
- Incoming Webhook stored in Secrets Manager
- Lambda function deployed to send alerts to Slack
- Mock CloudTrail events tested successfully

## Next Steps
- Implement IAM key abuse detection logic
- Automate infrastructure using Terraform
- Expand alerts to multi-account environments
