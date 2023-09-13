terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "host_sshkey"
  public_key = file(var.ssh_key)
}

data "aws_ami" "ec2_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical

}

resource "aws_instance" "csg_security_agent" {
  ami                    = data.aws_ami.ec2_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  count                  = var.instance_count
  tags = {
    Name = "csg_security_agent"
  }
}

resource "local_file" "hosts_ini" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      agents = aws_instance.csg_security_agent.*.public_dns
    }
  )
  filename = "../ansible/hosts.ini"
}

resource "local_file" "dns_hosts_ini" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      agents = [
        for i in range(0, length(aws_instance.csg_security_agent)) :
        "${var.record_name}-${i + 1}.${var.domain_name}"
      ]
    }
  )
  filename = "../ansible/dns-hosts.ini"
}
