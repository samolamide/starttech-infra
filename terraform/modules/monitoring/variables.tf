variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "asg_name" {
  type = string
}
