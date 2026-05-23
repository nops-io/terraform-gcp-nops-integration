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

# Enable Cloud Commerce Partner Procurement API in each distinct billing export project
resource "google_project_service" "cloud_commerce_partner_procurement" {
  for_each = local.billing_export_project_ids
  project  = each.key
  service  = "cloudcommerceprocurement.googleapis.com"

  disable_on_destroy         = var.disable_apis_on_destroy
  disable_dependent_services = false
}
