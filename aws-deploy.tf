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
  filename = "hosts.ini"
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
  filename = "dns-hosts.ini"
}

data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "site_domain" {
  count   = length(aws_instance.csg_security_agent)
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.record_name}-${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.csg_security_agent[count.index].public_ip]
}
