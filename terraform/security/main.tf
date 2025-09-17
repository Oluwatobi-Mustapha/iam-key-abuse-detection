provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_event_bus" "central_bus" {
  name = "org-security-bus"
}

resource "aws_cloudwatch_event_permission" "org_accounts" {
  principal      = "*"
  action         = "events:PutEvents"
  event_bus_name = aws_cloudwatch_event_bus.central_bus.name
}
