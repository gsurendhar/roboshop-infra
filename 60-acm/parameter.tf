
resource "aws_ssm_parameter" "acm_certificate_arn" {
  name  = "/${var.project}/${var.environment}/zone_id"
  type  = "String"
  value = aws_acm_certificate.gonela.arn
}