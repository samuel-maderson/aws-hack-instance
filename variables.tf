variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "aws-hack-instance"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}