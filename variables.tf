variable "ssh_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "ssh public key to use"
}
variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of security agent instances to deploy"
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "aws region to use"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "size of aws instances"
}

variable "domain_name" {
  type        = string
  default     = "agentstat.net"
  description = "Domain name in route53"
}

variable "record_name" {
  type        = string
  default     = "security-agent"
  description = "Record name to use for A records"
}



