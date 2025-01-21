variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro"
}

variable "environment" {
    description = "Name of environment"
    type        = string
    default     = "dev"
}

variable "key_name" {
    type = string
    default = "AWSraktelisGalutiniam"
}
