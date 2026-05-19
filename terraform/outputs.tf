output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (backend API URL)"
  value       = module.compute.alb_dns_name
}

output "alb_target_group_arn" {
  description = "ARN of the backend target group"
  value       = module.compute.target_group_arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "redis_primary_endpoint" {
  description = "ElastiCache Redis primary endpoint (host:port)"
  value       = module.networking.redis_endpoint
}

output "frontend_bucket_name" {
  description = "S3 bucket name for React static files"
  value       = module.storage.frontend_bucket_name
}

output "cloudfront_domain_name" {
  description = "CloudFront URL for the frontend"
  value       = module.storage.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation in CI/CD)"
  value       = module.storage.cloudfront_distribution_id
}

output "backend_log_group_name" {
  description = "CloudWatch log group for backend application logs"
  value       = module.monitoring.backend_log_group_name
}

output "ec2_instance_role_name" {
  description = "IAM role attached to backend EC2 instances"
  value       = module.compute.ec2_instance_role_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for backend Docker images"
  value       = module.compute.ecr_repository_url
}
