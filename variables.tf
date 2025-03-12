variable "cloudflare_api_key" {
  description = "Cloudflare Global API key"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_email" {
  description = "Cloudflare account email"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_main_zone_id" {
  description = "Cloudflare main zone ID"
  type        = string
  sensitive   = true
}
