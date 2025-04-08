resource "aws_acm_certificate" "dhoondlai_cert_cloudfront" {
  domain_name       = "api.dhoondlai.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
