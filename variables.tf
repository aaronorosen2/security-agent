variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "domain_name" {
  type    = string
  default = "agentstat.net"
}

variable "record_name" {
  type    = string
  default = "security-agent"
}



