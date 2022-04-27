data "aws_route53_zone" "example" {
  name = "niyokee.com"
}

resource "aws_route53_record" "example" {
  name    = data.aws_route53_zone.example.name
  zone_id = data.aws_route53_zone.example.zone_id
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
  }
}

resource "aws_route53_record" "example_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  zone_id = data.aws_route53_zone.example.zone_id
  ttl     = 60
}

output "domain_name" {
  value = aws_route53_record.example.name
}