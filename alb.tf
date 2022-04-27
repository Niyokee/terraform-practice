resource "aws_lb" "example" {
  name                       = "example"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id
  ]

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "this is http"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.example.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "this is https"
      status_code  = "200"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.example
  ]
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

module "http_sg" {
  source       = "./security_group"
  name         = "http_sg"
  vpc_id       = aws_vpc.example.id
  port         = 80
  cider_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source       = "./security_group"
  name         = "https_sg"
  vpc_id       = aws_vpc.example.id
  port         = 443
  cider_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source       = "./security_group"
  name         = "http_redirect_sg"
  vpc_id       = aws_vpc.example.id
  port         = 8080
  cider_blocks = ["0.0.0.0/0"]
}
