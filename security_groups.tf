

#########################################################
# CREATING SECURITY GROUPS
#########################################################
locals {
  security_group_rule_ingress = {
    app1_sg_rule = {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.security["alb_sg"].id
      security_group_id        = aws_security_group.security["app1_sg"].id
    }
    app2_sg_rule = {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.security["alb_sg"].id
      security_group_id        = aws_security_group.security["app2_sg"].id
    }
    registration_sg_rule = {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.security["alb_sg"].id
      security_group_id        = aws_security_group.security["registration_sg"].id
    }
    database_sg_rule = {
      from_port                = var.port
      to_port                  = var.port
      protocol                 = "tcp"
      source_security_group_id = aws_security_group.security["registration_sg"].id
      security_group_id        = aws_security_group.security["database_sg"].id
    }
  }
  security_group_alb = {
    http_rule = {
      from_port         = 80
      to_port           = 80
      protocol          = "tcp"
      security_group_id = aws_security_group.security["alb_sg"].id
      cidr_block        = ["0.0.0.0/0"]
    }
    https_rule = {
      from_port         = 443
      to_port           = 443
      protocol          = "tcp"
      security_group_id = aws_security_group.security["alb_sg"].id
      cidr_block        = ["0.0.0.0/0"]
    }
  }
  security_group_rule_egress = {
    alb_sg_rule = {
      to_port           = 0
      protocol          = "-1"
      cidr_block        = ["0.0.0.0/0"]
      from_port         = 0
      security_group_id = aws_security_group.security["alb_sg"].id
    }
    app1_sg_rule = {
      to_port           = 0
      protocol          = "-1"
      cidr_block        = ["0.0.0.0/0"]
      from_port         = 0
      security_group_id = aws_security_group.security["app1_sg"].id
    }
    app2_sg_rule = {
      to_port           = 0
      protocol          = "-1"
      cidr_block        = ["0.0.0.0/0"]
      from_port         = 0
      security_group_id = aws_security_group.security["app2_sg"].id
    }
    registration_sg_rule = {
      to_port           = 0
      protocol          = "-1"
      cidr_block        = ["0.0.0.0/0"]
      from_port         = 0
      security_group_id = aws_security_group.security["registration_sg"].id
    }
    database_sg_rule = {
      to_port           = 0
      protocol          = "-1"
      cidr_block        = ["0.0.0.0/0"]
      from_port         = 0
      security_group_id = aws_security_group.security["database_sg"].id
    }
  }
  security_group = {
    alb_sg = {
      name        = "${var.component}_alb_sg"
      description = "Allow http and https to the alb"
    }
    app1_sg = {
      name        = "${var.component}_app1_sg"
      description = "allow alb on port 80"
    }
    app2_sg = {
      name        = "${var.component}_app2_sg"
      description = "allo alb on port 80"
    }
    registration_sg = {
      name        = "${var.component}_registration_sg"
      description = "allow alb on port 8080"
    }
    database_sg = {
      name        = "${var.component}_database_sg"
      description = "allow registration app on port ${var.port}"
    }
  }

}

resource "aws_security_group" "security" {
  for_each    = local.security_group
  name        = each.value.name
  description = each.value.description
  vpc_id      = local.vpc_id


  tags = {
    Name = "${var.component}_${each.key}"
  }
}

resource "aws_security_group_rule" "ingress_rule_alb" {
  for_each = local.security_group_alb
  type     = "ingress"

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = "tcp"
  cidr_blocks       = each.value.cidr_block
  security_group_id = each.value.security_group_id


}

resource "aws_security_group_rule" "egress_rule" {
  for_each          = local.security_group_rule_egress
  type              = "egress"
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_block
  from_port         = each.value.from_port
  security_group_id = each.value.security_group_id
}

#########################################################
# CREATING APP1 SECURITY GROUP
#########################################################

resource "aws_security_group_rule" "ingress_rule" {
  for_each                 = local.security_group_rule_ingress
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  security_group_id        = each.value.security_group_id
}

# resource "aws_security_group_rule" "egress_rule_app1" {
#   type              = "egress"
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 0
#   security_group_id = aws_security_group.security["app1_sg"].id
# }

#########################################################
# CREATING APP2 SECURITY GROUP
#########################################################

# resource "aws_security_group_rule" "app2_sg" {
#     for_each = local.security_group_rule_rest
#   type              = "ingress"
#   from_port         = each.value.from_port
#   to_port           = each.value.to_port
#   protocol          = each.value.protocol
#   source_security_group_id = each.value.source_security_group_id  
#   security_group_id = each.value.security_group_id
# }

# resource "aws_security_group_rule" "egress_rule_app2" {
#   type              = "egress"
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 0
#   security_group_id = aws_security_group.security["app2_sg"].id
# }

#########################################################
# CREATING REGISTRATION APP SECURITY GROUP
#########################################################

#########################################################
# CREATING DATABASE SECURITY GROUP
#########################################################



