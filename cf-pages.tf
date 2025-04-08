resource "cloudflare_pages_project" "dhoondlai" {
  account_id        = var.cloudflare_account_id
  name              = "dhoondlai-frontend"
  production_branch = "main"
  source {
    type = "github"
    config {
      owner                         = "Dhoondlai"
      repo_name                     = "frontend"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "custom"
      preview_branch_includes       = ["preview"]
    }
  }

  build_config {
    build_command   = "npm run build"
    destination_dir = "dist"
  }


  deployment_configs {
    preview {
      compatibility_flags = ["nodejs_compat"]
    }
    production {
      compatibility_flags = ["nodejs_compat"]
      environment_variables = {
        "VITE_API_URL" = "https://api.dhoondlai.com",
      }
    }
  }
}

resource "cloudflare_pages_domain" "dhoondlai" {
  account_id   = var.cloudflare_account_id
  project_name = resource.cloudflare_pages_project.dhoondlai.name
  domain       = "dhoondlai.com"
}
