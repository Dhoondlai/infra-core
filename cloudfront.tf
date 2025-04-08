data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_policy" {
  name = "Managed-AllViewerExceptHostHeader"
}

module "cdn_backend" {
  source = "terraform-aws-modules/cloudfront/aws"

  enabled = true
  comment = "Dhoondlai Backend CDN"

  aliases = ["api.dhoondlai.com"]

  default_root_object = "index.html"
  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "Lambda-${module.backend-dhoondlai.lambda_function_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior = [
    {
      path_pattern             = "/api/*"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD", "OPTIONS"]
      target_origin_id         = "Lambda-${module.backend-dhoondlai.lambda_function_name}"
      viewer_protocol_policy   = "redirect-to-https"
      compress                 = true
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_policy.id
      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      use_forwarded_values     = false
    }
  ]

  price_class = "PriceClass_100" # Can be adjusted (100, 200, or All)

  # Set the origin
  origin = [
    # backend lambda.
    {
      domain_name              = "${module.backend-dhoondlai.lambda_function_url_id}.lambda-url.us-east-1.on.aws"
      origin_id                = "Lambda-${module.backend-dhoondlai.lambda_function_name}"
      origin_access_control_id = aws_cloudfront_origin_access_control.lambda_backend.id
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  custom_error_response = [
    {
      error_code            = 403
      response_code         = 403
      response_page_path    = "/index.html"
      error_caching_min_ttl = 300
    }
  ]

  # Viewer certificate - HTTPS
  # viewer_certificate = {
  #   acm_certificate_arn      = resource.aws_acm_certificate.parhlai_cert_cloudfront.arn
  #   ssl_support_method       = "sni-only"
  #   minimum_protocol_version = "TLSv1"
  # }
}

resource "aws_cloudfront_origin_access_control" "lambda_backend" {
  name                              = "dhoondlai-backend-lambda-access"
  description                       = "Access policy for the Dhoondlai lambda backend."
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
