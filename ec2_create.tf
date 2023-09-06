terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "host_sshkey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ec2_sg" {
  name        = "allow_http and ssh"
  description = "Allow http inbound traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-ec2-security-group"
  }
}

resource "aws_instance" "csg_security_agent" {
  ami             = var.ami
  instance_type   = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name      = aws_key_pair.ssh_key.key_name
  count           = 1
  tags = {
    Name = "csg_security_agent"
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      agents = aws_instance.csg_security_agent.*.public_ip
    }
  )
  filename = "hosts.ini"
}
