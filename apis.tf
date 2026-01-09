# Enable Cloud Asset API in billing export project
resource "google_project_service" "cloud_asset" {
  project = var.billing_export_project_id
  service = "cloudasset.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Cloud Billing API in billing export project
resource "google_project_service" "cloud_billing" {
  project = var.billing_export_project_id
  service = "cloudbilling.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable Recommender API in billing export project
# Note: Recommender API needs to be enabled per project, but recommendations are scoped to billing account
resource "google_project_service" "recommender" {
  project = var.billing_export_project_id
  service = "recommender.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

# Enable BigQuery Reservation API in billing export project (optional)
# Only enable if using flat-rate or reservation-based BigQuery pricing (for capacity commitments)
# Most customers use on-demand pricing and can skip this
resource "google_project_service" "bigquery_reservation" {
  count   = var.enable_bigquery_reservation_api ? 1 : 0
  project = var.billing_export_project_id
  service = "bigqueryreservation.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}

