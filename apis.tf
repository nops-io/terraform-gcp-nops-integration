# Enable Cloud Asset API in each distinct billing export project
resource "google_project_service" "cloud_asset" {
  for_each = local.billing_export_project_ids
  project  = each.key
  service  = "cloudasset.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Cloud Billing API in each distinct billing export project
resource "google_project_service" "cloud_billing" {
  for_each = local.billing_export_project_ids
  project  = each.key
  service  = "cloudbilling.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Recommender API in each distinct billing export project
# Note: Recommender API needs to be enabled per project, but recommendations are scoped to billing account
resource "google_project_service" "recommender" {
  for_each = local.billing_export_project_ids
  project  = each.key
  service  = "recommender.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable BigQuery Reservation API in each distinct billing export project (optional)
# Only enable if using flat-rate or reservation-based BigQuery pricing (for capacity commitments)
# Most customers use on-demand pricing and can skip this
resource "google_project_service" "bigquery_reservation" {
  for_each = var.enable_bigquery_reservation_api ? local.billing_export_project_ids : toset([])
  project  = each.key
  service  = "bigqueryreservation.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

