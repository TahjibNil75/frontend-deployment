variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default = "HeyGen-Roleplay-Bot"
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS region where resources will be created"
  type        = string
  default = "mlbd-tahjib"
}


