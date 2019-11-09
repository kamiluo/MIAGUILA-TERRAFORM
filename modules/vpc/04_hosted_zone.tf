#-------------------------------------------------------------------------------------
#--Privated Hosted Zone
#-------------------------------------------------------------------------------------

resource "aws_route53_zone" "route53_ma_private" {
  name = "devops-test-miaguila.com"

  vpc {
    vpc_id = "${aws_vpc.vpc_ma.id}"
  }
}

resource "aws_route53_record" "reoute_53_nlb_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "api.devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_alb.nlb_ma_ec2_microservices.dns_name}"
    zone_id                = "${aws_alb.nlb_ma_ec2_microservices.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_record_alb_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_alb.alb_ma_ec2_webpage.dns_name}"
    zone_id                = "${aws_alb.alb_ma_ec2_webpage.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_record_s3_dns" {
  zone_id = "${aws_route53_zone.route53_ma_private.zone_id}"
  name    = "admin.devops-test-miaguila.com"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.s3_ma_admin.website_domain}"
    zone_id                = "${aws_s3_bucket.s3_ma_admin.hosted_zone_id}"
    evaluate_target_health = true
  }
}