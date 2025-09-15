# variables.tf
# Placeholder for Terraform variables

variable "lambda_function_name" {
  type    = string
  default = "iam_key_abuse_alert"
}

variable "slack_webhook_secret_name" {
  type    = string
  default = "slack_webhook_url"
}

# TODO: Add more variables as needed
