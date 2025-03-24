data "mongodbatlas_roles_org_id" "this" {}

data "mongodbatlas_atlas_user" "admin" {
  username = var.mongodb_atlas_account_email
}

resource "mongodbatlas_project" "dhoondlai" {
  name             = "dhoondlai-${var.environment}"
  org_id           = data.mongodbatlas_roles_org_id.this.org_id
  project_owner_id = data.mongodbatlas_atlas_user.admin.id
}

resource "mongodbatlas_advanced_cluster" "dhoondlai_db" {
  project_id   = mongodbatlas_project.dhoondlai.id
  name         = "dhoondlaidb-${var.environment}"
  cluster_type = "REPLICASET"
  #mongo_db_major_version = 8.0 # Read only for "Tenant" provider
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M0"
      }
      region_name           = "US_EAST_1"
      provider_name         = "TENANT"
      backing_provider_name = "AWS"
      priority              = 7
    }
  }
}

resource "mongodbatlas_database_user" "dhoondlai_db_user" {
  project_id         = mongodbatlas_project.dhoondlai.id
  auth_database_name = "$external"
  username           = aws_iam_role.backend_lambda_role.arn
  aws_iam_type       = "ROLE"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}

resource "mongodbatlas_database_user" "dhoondlai_db_scraper_user" {
  project_id         = mongodbatlas_project.dhoondlai.id
  auth_database_name = "$external"
  username           = aws_iam_role.scraper_lambda_role.arn
  aws_iam_type       = "ROLE"

  roles {
    role_name     = "readWrite"
    database_name = "dhoondlai"
  }
}
