data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs               = slice(data.aws_availability_zones.available.names, 0, 2)
  backend_log_group = "/${var.project_name}/${var.environment}/backend"
}

module "networking" {
  source = "./modules/networking"

  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = local.azs
  backend_port    = var.backend_port
  redis_node_type = var.redis_node_type
}

module "compute" {
  source = "./modules/compute"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  public_subnet_ids    = module.networking.public_subnet_ids
  private_subnet_ids   = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ec2_security_group_id = module.networking.ec2_security_group_id
  instance_type        = var.instance_type
  backend_port         = var.backend_port
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  log_group_name       = local.backend_log_group
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name         = var.project_name
  environment          = var.environment
  log_retention_days   = var.log_retention_days
  alb_arn_suffix          = module.compute.alb_arn_suffix
  target_group_arn_suffix = module.compute.target_group_arn_suffix
  asg_name                = module.compute.asg_name
}
