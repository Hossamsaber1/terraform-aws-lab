variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnets" {
  description = "Map of subnets"
  type = map(object({
    cidr = string
    type = string
  }))
}

variable "instance_names" {
  description = "Names of EC2 instances"
  type        = list(string)
  default     = ["bastion", "app"]
}