output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}

output "alb_arn" {
  value = aws_lb.backend.arn
}

output "alb_arn_suffix" {
  description = "CloudWatch dimension for ALB metrics (app/name/id)"
  value       = join("/", slice(split("/", aws_lb.backend.arn), 1, 4))
}

output "target_group_arn_suffix" {
  description = "CloudWatch dimension for target group metrics"
  value       = "targetgroup/${element(split("targetgroup/", aws_lb_target_group.backend.arn), 1)}"
}

output "target_group_arn" {
  value = aws_lb_target_group.backend.arn
}

output "asg_name" {
  value = aws_autoscaling_group.backend.name
}

output "ec2_instance_role_name" {
  value = aws_iam_role.ec2.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "ecr_repository_name" {
  value = aws_ecr_repository.backend.name
}
