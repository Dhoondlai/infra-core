resource "cloudflare_record" "dhoondlai" {
  content = "dhoondlai-frontend.pages.dev"
  name    = "dhoondlai.com"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = var.cloudflare_main_zone_id
  comment = "Core frontend application hosted on cloudflare pages."
}

resource "cloudflare_record" "www_dhoondlai" {
  content = "dhoondlai-frontend.pages.dev"
  name    = "www.dhoondlai.com"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = var.cloudflare_main_zone_id
  comment = "Core frontend application hosted on cloudflare pages."
}

resource "cloudflare_record" "dhoondlai_api" {
  content = module.cdn_backend.cloudfront_distribution_domain_name
  name    = "api.dhoondlai.com"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  zone_id = var.cloudflare_main_zone_id
  comment = "API endpoint for dhoondlai. Hosted on AWS (Cloudfront + Lambda)."
}

# Validation for the ACM certificate

resource "cloudflare_record" "acm_validation_cloudfront" {
  comment = "Domain validation for ACM certificate to route api.dhoondlai.com to Cloudfront"
  content = one(resource.aws_acm_certificate.parhlai_cert_cloudfront.domain_validation_options).resource_record_value
  name    = one(resource.aws_acm_certificate.parhlai_cert_cloudfront.domain_validation_options).resource_record_name
  proxied = false
  type    = one(resource.aws_acm_certificate.parhlai_cert_cloudfront.domain_validation_options).resource_record_type
  zone_id = var.cloudflare_main_zone_id #parhlai.com zone
}

