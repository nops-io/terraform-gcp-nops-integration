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

  # Target customer projects with GKE
  # If enable_gke_apis_for_all_projects is true, use all projects
  # Otherwise, use only projects in target_gke_project_ids
  # Note: auto_detect_gke_projects is reserved for future enhancement
  gke_projects = var.enable_gke_apis_for_all_projects ? local.all_projects : {
    for project_id, project in local.all_projects : project_id => project
    if contains(var.target_gke_project_ids, project_id)
  }
}

# Enable Cloud Asset API in Central Ingestion Project
resource "google_project_service" "cloud_asset_central" {
  count   = var.enable_cloud_asset_api ? 1 : 0
  project = local.central_ingestion_project
  service = "cloudasset.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Cloud Billing API in Central Ingestion Project
resource "google_project_service" "cloud_billing_central" {
  count   = var.enable_cloud_billing_api ? 1 : 0
  project = local.central_ingestion_project
  service = "cloudbilling.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Recommender API in all projects (enabled at billing account level)
# Note: Recommender API needs to be enabled per project, but recommendations are scoped to billing account
resource "google_project_service" "recommender_all" {
  for_each = var.enable_recommender_api ? local.all_projects : {}
  project  = each.value.project_id
  service  = "recommender.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Kubernetes Engine API in target GKE projects (always enabled)
resource "google_project_service" "container_gke_projects" {
  for_each = local.gke_projects
  project  = each.value.project_id
  service  = "container.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable BigQuery Reservation API
# Scope not specified, enabling in all projects by default
# Can be customized via variables
resource "google_project_service" "bigquery_reservation" {
  for_each = var.enable_bigquery_reservation_api ? local.all_projects : {}
  project  = each.value.project_id
  service  = "bigqueryreservation.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Cloud Run Admin API in all projects
resource "google_project_service" "cloud_run_admin" {
  for_each = var.enable_cloud_run_admin_api ? local.all_projects : {}
  project  = each.value.project_id
  service  = "run.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Cloud SQL Admin API in all projects
resource "google_project_service" "cloud_sql_admin" {
  for_each = var.enable_cloud_sql_admin_api ? local.all_projects : {}
  project  = each.value.project_id
  service  = "sqladmin.googleapis.com"

  disable_on_destroy = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Grant organization-level IAM roles to nOps service account
# These roles provide fleet-wide visibility for asset enumeration, recommendations, and resource analysis
resource "google_organization_iam_member" "nops_cloudasset_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_browser" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/browser"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_recommender_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/recommender.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_logging_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/logging.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_compute_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/compute.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_container_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/container.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_cloudsql_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/cloudsql.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_run_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/run.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

