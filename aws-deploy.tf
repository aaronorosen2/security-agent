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

resource "aws_security_group" "ec2_sg" {
  name        = "allow https and ssh"
  description = "Allow https inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-ec2-security-group"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical

}

resource "aws_instance" "csg_security_agent" {
  ami                    = data.aws_ami.ubuntu.id
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
  filename = "ansible/hosts.ini"
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
  filename = "ansible/dns-hosts.ini"
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "agentstat.net" = {
		domain_name = "agentstat.net"
    }
  }
}

module "records" {
 source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  count   = length(aws_instance.csg_security_agent)
  records = [
    {
		name    = "${var.record_name}-${count.index + 1}"
      type    = "A"
      ttl     = 3600
		records = [aws_instance.csg_security_agent[count.index].public_ip]
    },
  ]

  depends_on = [module.zones]
}
