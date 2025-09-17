resource "aws_cloudwatch_event_rule" "from_workloads" {
  name          = "from-workloads"
  description   = "Receive forwarded events from workload accounts"
  event_bus_name = aws_cloudwatch_event_bus.central_bus.name

  event_pattern = <<EOF
{
  "source": ["aws.iam"]
}
EOF
}

resource "aws_cloudwatch_event_target" "lambda_alert" {
  rule          = aws_cloudwatch_event_rule.from_workloads.name
  target_id     = "send-to-lambda"
  arn           = aws_lambda_function.iam_key_abuse.arn
  event_bus_name = aws_cloudwatch_event_bus.central_bus.name
}
