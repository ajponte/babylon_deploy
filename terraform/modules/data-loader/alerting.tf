# ==============================================================================
# Data Loader Failure Alerting & Async Event Destination
# ==============================================================================

# SNS topic for data loader error alarms and async on-failure destination events
resource "aws_sns_topic" "data_loader_alerts" {
  name              = "babylon-data-loader-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = var.tags
}

# CloudWatch metric alarm on Lambda execution errors
resource "aws_cloudwatch_metric_alarm" "data_loader_errors" {
  alarm_name          = "babylon-data-loader-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when Babylon Data Loader Lambda encounters execution errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.data_loader.function_name
  }

  alarm_actions = [aws_sns_topic.data_loader_alerts.arn]
  ok_actions    = [aws_sns_topic.data_loader_alerts.arn]

  tags = var.tags
}

# Async invoke configuration with retry policy and on-failure destination
resource "aws_lambda_function_event_invoke_config" "data_loader" {
  function_name                = aws_lambda_function.data_loader.function_name
  maximum_retry_attempts       = 2
  maximum_event_age_in_seconds = 3600

  destination_config {
    on_failure {
      destination = aws_sns_topic.data_loader_alerts.arn
    }
  }
}

# ==============================================================================
# Alerting Outputs
# ==============================================================================

output "alerts_topic_arn" {
  description = "ARN of the SNS topic for Data Loader alerts and async on-failure destinations"
  value       = aws_sns_topic.data_loader_alerts.arn
}
