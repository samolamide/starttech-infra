variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "backend_port" {
  type = number
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}
