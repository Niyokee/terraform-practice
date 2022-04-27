variable "name" {}
variable "vpc_id" {}
variable "port" {}
variable "cider_blocks" {
  type = list(string)
}

resource "aws_security_group" "default" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress_default" {
  from_port         = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.default.id
  to_port           = var.port
  cidr_blocks       = var.cider_blocks
  type              = "ingress"
}

resource "aws_security_group_rule" "egress_default" {
  from_port         = var.port
  protocol          = "-1"
  security_group_id = aws_security_group.default.id
  cidr_blocks       = var.cider_blocks
  to_port           = var.port
  type              = "egress"
}

output "security_group_id" {
  value = aws_security_group.default.id
}