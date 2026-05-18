variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.0.0/25"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.0.128/25"
}

variable "public_az" {
  description = "Public subnet AZ"
  type        = string
  default     = "ap-south-1a"
}

variable "private_az" {
  description = "Private subnet AZ"
  type        = string
  default     = "ap-south-1b"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
  default     = "ami-0af878be293432b08" #replace with your desired ami id
}

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}