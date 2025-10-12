variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  default     = "ami-052064a798f08f0d3"
}

variable "key_name" {
  description = "Key Pair of EC2"
  default     = "key_name"
}


