variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "mongodb_atlas_account_email" {
  description = "MongoDB Atlas account email"
  type        = string
  default     = "dhoondlai@gmail.com"
}

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

variable "mongodbatlas_public_key" {
  description = "MongoDB Atlas public key"
  type        = string
  sensitive   = true
}

variable "mongodbatlas_private_key" {
  description = "MongoDB Atlas private key"
  type        = string
  sensitive   = true
}
