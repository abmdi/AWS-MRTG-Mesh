variable "project_name" {
  type        = string
  description = "Project name prefix for resources."
  default     = "mrtg-mesh"
}

variable "environment" {
  type        = string
  description = "Environment type (prod/dev)."
  default     = "prod"
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region."
  default     = "us-east-1"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region for multi-region mesh."
  default     = "eu-west-1"
}

variable "common_tags" {
  type        = map(string)
  description = "Shared resource tags."
  default = {
    ManagedBy   = "Terraform"
    Environment = "Production"
    Project     = "AWS-MRTG-Mesh"
  }
}
