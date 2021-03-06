locals {
  can_ssl           = var.ssl_certificate_arn == "" ? false : true
  can_domain        = var.domain_name == "" ? false : true
  is_only_http      = local.can_ssl == false && local.can_domain == true
  is_redirect_https = local.can_ssl && local.can_domain ? true : false
}

resource "aws_alb" "app_alb" {
  name            = "${var.cluster_name}-${var.environment}-alb-node"
  subnets         = var.availability_zones
  security_groups = [aws_security_group.alb_sg.id, aws_security_group.app_sg.id]

  tags = {
    Name        = "${var.cluster_name}-${var.environment}-alb-node"
    Environment = var.cluster_name
  }
}

resource "aws_alb_target_group" "api_target_group" {
  name        = "${var.cluster_name}-${var.environment}-tg-api"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path = var.helth_check_path
    port = var.container_port
  }

  depends_on = [aws_alb.app_alb]
}

resource "aws_alb_listener" "web_app" {
  count             = local.can_ssl ? 0 : 1
  load_balancer_arn = aws_alb.app_alb.arn
  port              = var.alb_port
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.api_target_group]

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "web_app_ssl" {
  count             = local.can_ssl ? 1 : 0
  load_balancer_arn = aws_alb.app_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"

  certificate_arn = var.ssl_certificate_arn

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "web_app_http" {
  count = local.is_only_http ? 1 : 0

  load_balancer_arn = aws_alb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.api_target_group]

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_redirect_https" {
  count = local.is_redirect_https ? 1 : 0

  load_balancer_arn = aws_alb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    target_group_arn = aws_alb_target_group.api_target_group.arn
    type = "forward"
  }
}