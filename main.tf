terraform {
  required_version = ">= 1.0"
}

# Data source to get all projects in the organization
data "google_projects" "org_projects" {
  filter = "parent.id:${var.organization_id} parent.type:organization"
}

# Local values to organize projects by type
locals {
  # Central Ingestion Project - specified by user
  central_ingestion_project = var.central_ingestion_project_id

  # All projects in the organization
  all_projects = {
    for project in data.google_projects.org_projects.projects : project.project_id => project
  }
}

