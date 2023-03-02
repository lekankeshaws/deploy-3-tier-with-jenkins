

#########################################################
# CREATING ALB
#########################################################

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 6.0"

#   name = "${var.component}-web-alb"

#   load_balancer_type = "application"

#   vpc_id          = local.vpc_id
#   subnets         = aws_subnet.public_subnet[*].id
#   security_groups = [aws_security_group.security["alb_sg"].id]

#   target_groups = [
#     {
#       name_prefix          = "app1-"
#       backend_protocol     = "HTTP"
#       backend_port         = 80
#       target_type          = "instance"
#       deregistration_delay = 10
#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/app1/index.html"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#         matcher             = "200-399"
#       }
#       protocol_version = "HTTP1"
#       targets = {
#         my_app1_vm1 = {
#           target_id = aws_instance.app1.id
#           port      = 80
#         }
#       }
#     },
#     {
#       name_prefix          = "app2-"
#       backend_protocol     = "HTTP"
#       backend_port         = 80
#       target_type          = "instance"
#       deregistration_delay = 10
#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/app2/index.html"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#         matcher             = "200-399"
#       }
#       protocol_version = "HTTP1"
#       targets = {
#         my_app2_vm2 = {
#           target_id = aws_instance.app2.id
#           port      = 80
#         }
#       }
#     },
#     {
#       name_prefix          = "reg-"
#       backend_protocol     = "HTTP"
#       backend_port         = 8080
#       target_type          = "instance"
#       deregistration_delay = 10
#       health_check = {
#         enabled             = true
#         interval            = 30
#         path                = "/login"
#         port                = "traffic-port"
#         healthy_threshold   = 3
#         unhealthy_threshold = 3
#         timeout             = 6
#         protocol            = "HTTP"
#         matcher             = "200-399"
#       }
#       protocol_version = "HTTP1"
#       targets = {
#         my_reg_vm1 = {
#           target_id = aws_instance.registration_app.id
#           port      = 8080
#         }
#       }
#     }
#   ]

#   https_listeners = [
#     {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = module.acm.acm_certificate_arn
#       action_type     = "fixed-response"
#       fixed_response = {
#         content_type = "text/plain"
#         message_body = "Fixed Static message - for Root Context"
#         status_code  = "200"
#       }
#     }
#   ]

#   http_tcp_listeners = [
#     {
#       port        = 80
#       protocol    = "HTTP"
#       action_type = "redirect"
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#   ]

#   https_listener_rules = [
#     {
#       https_listener_index = 0
#       priority             = 1
#       actions = [
#         {
#           type               = "forward"
#           target_group_index = 0
#         }
#       ]
#       conditions = [{
#         path_patterns = ["/app1*"]
#       }]
#     },
#     {
#       https_listener_index = 0
#       priority             = 2
#       actions = [
#         {
#           type               = "forward"
#           target_group_index = 1
#         }
#       ]
#       conditions = [{
#         path_patterns = ["/app2*"]
#       }]
#     },
#     {
#       https_listener_index = 0
#       priority             = 3
#       actions = [
#         {
#           type               = "forward"
#           target_group_index = 2
#         }
#       ]
#       conditions = [
#         {
#           path_patterns = ["/*"]
#         }
#       ]
#     },
#   ]

#   tags = {
#     Environment = "Test"
#   }
# }

# data "aws_route53_zone" "this" {
#   name = var.dns_name
# }

# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.this.zone_id
#   name    = var.dns_name
#   type    = "A"

#   alias {
#     name                   = module.alb.lb_dns_name
#     zone_id                = module.alb.lb_zone_id
#     evaluate_target_health = true
#   }
# }

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 3.0.0"

#   domain_name = data.aws_route53_zone.this.name
#   zone_id     = data.aws_route53_zone.this.zone_id

#   subject_alternative_names = var.subject_alternative_names

# }