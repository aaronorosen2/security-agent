variable "network_interface_id" {
  type    = string
  default = "network_id_from_aws"
}

variable "ami" {
  type    = string
  default = "ami-04d1dcfb793f6fa37"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


