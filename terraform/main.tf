# main.tf
# Terraform configuration placeholder for IAM Key Abuse Detection Project
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# TODO: Add Lambda, EventBridge, IAM roles, and Secrets Manager resources
