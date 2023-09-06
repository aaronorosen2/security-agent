terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    godaddy = {
      source = "n3integration/godaddy"
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

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical

}

resource "aws_instance" "csg_security_agent" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name
  count                  = 1
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

resource "godaddy_domain_record" "gd-fancy-domain" {
  domain = "realtorstat.com"

  nameservers = [
    "ns27.domaincontrol.com",
    "ns28.domaincontrol.com",
  ]


  record {
    data     = "130.127.133.103"
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }
  record {
    data     = "130.127.133.103"
    name     = "admin"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }
  record {
    data     = "130.127.133.103"
    name     = "app"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }
  record {
    data     = "130.127.133.103"
    name     = "v2"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }
  record {
    data     = "130.127.133.103"
    name     = "www"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }
  record {
    data     = "3IpI2h5Mqux4SxxFgwWQQNLJnMqXn6SrW27-6uu6kzQ"
    name     = "_acme-challenge.admin"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "5Qc1OfkhivW1r3BNkpJdtKpEOyoC2UEWVc5Z2opURA8"
    name     = "_acme-challenge.www"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "KjWULfv6voVUlSlLXPdEJU66YWc5-p95ihmxFhiRHik"
    name     = "_acme-challenge"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "NETORGFT14405637.onmicrosoft.com"
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "ShWk7FKbG4T-7wTVNTYlnymmIggZ15XN6mo3-VW5t2U"
    name     = "_acme-challenge.app"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "aisqyzomd4k65wosv4rljp23a7w2ayjd.dkim.amazonses.com"
    name     = "aisqyzomd4k65wosv4rljp23a7w2ayjd._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "autodiscover.outlook.com"
    name     = "autodiscover"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "clientconfig.microsoftonline-p.net"
    name     = "msoid"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "email.secureserver.net"
    name     = "email"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "esgvtd4xwp2awayzewfkl2zdwgmvfojl.dkim.amazonses.com"
    name     = "esgvtd4xwp2awayzewfkl2zdwgmvfojl._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "google-site-verification=y6TdrzsdkKTQtzqE0grBTsZN_ox0iweBVSl2uVaobE0"
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "grofjhcghtugm65u7qbaovcjgrtv2xnq.dkim.amazonses.com"
    name     = "grofjhcghtugm65u7qbaovcjgrtv2xnq._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "j3qa4m34qesdcqtkfe3wffmhkgujr6yc.dkim.amazonses.com"
    name     = "j3qa4m34qesdcqtkfe3wffmhkgujr6yc._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "kb6ppddu434e7oe6hlm6i4ks3ftrppei.dkim.amazonses.com"
    name     = "kb6ppddu434e7oe6hlm6i4ks3ftrppei._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "realtorstat-com.mail.protection.outlook.com"
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "MX"
    weight   = 0
  }
  record {
    data     = "rjrgepqx4ztoiyxfn3giv6mvdu5lnpqu.dkim.amazonses.com"
    name     = "rjrgepqx4ztoiyxfn3giv6mvdu5lnpqu._domainkey"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "sipdir.online.lync.com"
    name     = "@"
    port     = 443
    priority = 100
    protocol = "_tls"
    service  = "_sip"
    ttl      = 3600
    type     = "SRV"
    weight   = 1
  }
  record {
    data     = "sipdir.online.lync.com"
    name     = "sip"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = "sipfed.online.lync.com"
    name     = "@"
    port     = 5061
    priority = 100
    protocol = "_tcp"
    service  = "_sipfederationtls"
    ttl      = 3600
    type     = "SRV"
    weight   = 1
  }
  record {
    data     = "tt8sILXK_jqdCBSiBHlAZ755iUEfHC-mPnGDyjqg4JA"
    name     = "_acme-challenge.v2"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "v=spf1 include:secureserver.net -all"
    name     = "@"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "TXT"
    weight   = 0
  }
  record {
    data     = "webdir.online.lync.com"
    name     = "lyncdiscover"
    port     = 0
    priority = 0
    ttl      = 3600
    type     = "CNAME"
    weight   = 0
  }
  record {
    data     = aws_instance.csg_security_agent[0].public_ip
    name     = "security-agent"
    port     = 0
    priority = 0
    ttl      = 600
    type     = "A"
    weight   = 0
  }


}

