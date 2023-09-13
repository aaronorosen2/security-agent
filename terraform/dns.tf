module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 2.0"

  zones = {
    "${var.domain_name}" = {
      domain_name = "${var.domain_name}"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  count = length(aws_instance.csg_security_agent)
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
