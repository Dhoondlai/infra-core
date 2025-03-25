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
