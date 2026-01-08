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

