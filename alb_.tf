

#########################################################
# CREATING ALB
#########################################################

resource "aws_lb" "web_alb" {
  name               = "${var.component}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security["alb_sg"].id]
  subnets            = module.vpc.public_subnet_id

  tags = {
    Environment = "${var.component}-alb"
  }
}

resource "aws_lb_listener" "frontend_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed Static message - for Root Context"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "https_listener_rule_app1" {
  count        = length(aws_lb_target_group.app_tg)
  listener_arn = aws_lb_listener.frontend_https.arn
  priority     = var.alb_priority[count.index]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[count.index].arn
  }
  condition {
    path_pattern {
      values = [
        var.rule_value[count.index]
      ]
    }
  }
}

resource "aws_lb_listener_rule" "https_listener_rule_reg" {
  listener_arn = aws_lb_listener.frontend_https.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reg_tg.arn
  }
  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }
}

resource "aws_lb_target_group" "app_tg" {
  count                = length(var.health_path)
  vpc_id               = local.vpc_id
  deregistration_delay = "10"
  name_prefix          = "app${count.index + 1}-"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  protocol_version     = "HTTP1"

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    protocol            = "HTTP"
    path                = var.health_path[count.index]
    matcher             = "200-399"
  }

}

resource "aws_lb_target_group" "reg_tg" {
  vpc_id               = local.vpc_id
  deregistration_delay = "10"
  name_prefix          = "reg-"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "instance"
  protocol_version     = "HTTP1"

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    protocol            = "HTTP"
    path                = "/login"
    matcher             = "200-399"
  }

}

locals {
  target_ass = {
    tg_ass_app1 = {
      target_group_arn = aws_lb_target_group.app_tg[0].arn
      target_id        = aws_instance.app1.id
      port             = 80
    }
    tg_ass_app2 = {
      target_group_arn = aws_lb_target_group.app_tg[1].arn
      target_id        = aws_instance.app2.id
      port             = 80
    }
  }
}

resource "aws_lb_target_group_attachment" "tg_ass_app" {
  for_each         = local.target_ass
  target_group_arn = each.value.target_group_arn
  target_id        = each.value.target_id
  port             = each.value.port
}

resource "aws_lb_target_group_attachment" "reg_ass_app" {
  target_group_arn = aws_lb_target_group.reg_tg.arn
  target_id        = aws_instance.registration_app.id
  port             = 8080
}

#########################################################
# CREATING AMAZON CERTIFICATE MANAGER
#########################################################

resource "aws_acm_certificate" "cert" {
  domain_name               = var.dns_name
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "test"
  }

}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_zone : record.fqdn]
}

#########################################################
# CREATING ROUTE 53 RESOURCES
#########################################################

data "aws_route53_zone" "this" {
  name         = var.dns_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "route53_zone" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.this.zone_id
}

