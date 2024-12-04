variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

