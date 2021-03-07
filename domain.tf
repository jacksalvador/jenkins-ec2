# Control aws Route53 Hosted Zone, Record and ACM Certificates 

provider "aws" {
    alias = "east"
    region = "us-east-1"  # To use CloudFront choose region us-east-1  
}

resource "aws_route53_zone" "gumggom_route53_zone" {
  name = "gumggom.ga"

  tags = {
    Domain = "gumggom.ga"
  }
}

resource "aws_route53_record" "gumggom_route53_record" {
  zone_id = aws_route53_zone.gumggom_route53_zone.zone_id
  name    = "dev.gumggom.ga"
  type    = "A"
  alias {
    name                   = "d3bj85c3u3t4k8.cloudfront.net"  # aws_cdn.main.dns_name
    zone_id                = "E1LRI415R38KO9"                 # aws_cdn.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "private_route53_zone" {
  name = "stage.mi.singlex.com"

    tags = {
    Domain    = "stage.mi.singlex.com"
    Purpose   = "Test"
  }

  vpc {
    vpc_id = aws_vpc.vpc_yang.id
  }
}

resource "aws_route53_record" "private_route53_record" {
  zone_id = aws_route53_zone.private_route53_zone.zone_id
  name    = "stage.mi.singlex.com"
  type    = "A"
  ttl     = "300"
  records = ["3.35.154.17"] # [aws_eip.lb.public_ip]
}

resource "aws_acm_certificate" "gumggom_acm_certificate" {
  provider          = aws.east
  domain_name       = "*.gumggom.ga"
  subject_alternative_names = ["gumgom.ga"]
  validation_method = "DNS"

  tags = {
    Name      = "gumggom.ga"
    Admin     = "Admin"
    Environment = "Prod"
    Purpose   = "Website"
    Protocol  = "TLS"
    Registrar = "Route53"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "gumggom_route53_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.gumggom_acm_certificate.domain_validation_options: dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.gumggom_route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "gumggom_application_cert" {
  certificate_arn         = aws_acm_certificate.gumggom_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.gumggom_route53_cert_validation: record.fqdn]
}