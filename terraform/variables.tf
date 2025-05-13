# Variables
# set variables in .env file

# variable "AWS_ACCESS_KEY_ID" {
#   description = "AWS access key"
#   type        = string
#   sensitive   = true
# }

# variable "AWS_SECRET_ACCESS_KEY" {
#   description = "AWS secret key"
#   type        = string
#   sensitive   = true
# }

# variable "AWS_DEFAULT_REGION" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-1"
# }

variable "waf_name" {
  description = "Name for the WAF Web ACL"
  type        = string
  default     = "my-waf-web-acl"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  default = "vpc-0635ff1b62125588b"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the Application Load Balancer (minimum 2 subnets in different AZs)"
  type        = list(string)
  default     = ["subnet-066c2d3d16fe257e7", "subnet-0d6f9bc18688e55fd"]
}