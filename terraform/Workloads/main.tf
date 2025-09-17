provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_event_rule" "iam_activity" {
  name        = "iam-activity-forward"
  description = "Forward IAM activity events to Security Account"

  event_pattern = <<EOF
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"]
}
EOF
}

resource "aws_cloudwatch_event_target" "forward_to_security" {
  rule      = aws_cloudwatch_event_rule.iam_activity.name
  target_id = "to-security"
  arn       = "arn:aws:events:us-east-1:<SECURITY_ACCOUNT_ID>:event-bus/org-security-bus"
}
