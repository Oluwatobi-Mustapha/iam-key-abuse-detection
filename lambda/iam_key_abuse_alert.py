import boto3
import json
import urllib.request

# Fetch Slack webhook from Secrets Manager
def get_slack_webhook():
    secrets = boto3.client("secretsmanager")
    response = secrets.get_secret_value(SecretId="slack_webhook_url")
    return response["SecretString"]

# Send message to Slack
def notify_slack(message, severity="info"):
    slack_url = get_slack_webhook()
    
    # Add emoji based on severity
    emoji = {
        "info": ":information_source:",
        "warning": ":warning:",
        "critical": ":rotating_light:"
    }.get(severity, ":speech_balloon:")
    
    payload = {
        "text": f"{emoji} *Cloud Alert:* {message}"
    }
    
    req = urllib.request.Request(
        slack_url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
    )
    urllib.request.urlopen(req)

# Main Lambda handler
def lambda_handler(event, context):
    """
    Handles incoming AWS events and sends them to Slack.
      - Root login
      - IAM role change
      - GuardDuty finding
      - CloudTrail event
    """
    
    print("Received event:", json.dumps(event))  # log full event
    
    # Default message
    message = "New AWS security event received."
    severity = "info"
    
    # Example: Root account login (from CloudTrail/CloudWatch event)
    if "detail" in event and event["detail"].get("eventName") == "ConsoleLogin":
        user = event["detail"].get("userIdentity", {}).get("arn", "unknown")
        message = f"Root login detected! User: {user}"
        severity = "critical"
    
    # Example: GuardDuty finding
    elif "detail-type" in event and event["detail-type"] == "GuardDuty Finding":
        finding = event["detail"]["title"]
        severity = "critical"
        message = f"GuardDuty finding: {finding}"
    
    # Example: IAM Policy change
    elif "detail" in event and event["detail"].get("eventSource") == "iam.amazonaws.com":
        action = event["detail"]["eventName"]
        user = event["detail"]["userIdentity"]["arn"]
        message = f"IAM event: {action} by {user}"
        severity = "warning"
    
    # Send to Slack
    notify_slack(message, severity)
    
    return {"statusCode": 200}

