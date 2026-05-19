resource "aws_cloudwatch_log_group" "backend" {
  name              = "/${var.project_name}/${var.environment}/backend"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-logs"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/${var.project_name}/${var.environment}/frontend"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-${var.environment}-frontend-logs"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-ops"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB request count"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB target 5xx"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Unhealthy targets"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]
          ]
          period = 60
          stat   = "Maximum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ASG average CPU"
          region = "us-east-1"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  alarm_description   = "ALB target 5xx errors exceeded threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-unhealthy-targets"
  alarm_description   = "One or more ALB targets are unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-asg-high-cpu"
  alarm_description   = "ASG average CPU is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}
