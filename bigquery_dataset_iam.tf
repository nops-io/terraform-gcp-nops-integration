# Grant BigQuery dataset-level IAM roles to nOps service account
# BigQuery Data Viewer role on billing export datasets

# Detailed Usage Cost dataset
resource "google_bigquery_dataset_iam_member" "nops_detailed_usage_cost" {
  count      = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" && var.bigquery_detailed_usage_cost_dataset_id != "" ? 1 : 0
  project    = local.detailed_usage_cost_project_id
  dataset_id = local.detailed_usage_cost_dataset_id_only
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

# Pricing dataset
resource "google_bigquery_dataset_iam_member" "nops_pricing" {
  count      = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" && var.bigquery_pricing_dataset_id != "" ? 1 : 0
  project    = local.pricing_project_id
  dataset_id = local.pricing_dataset_id_only
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

# Committed Use Discounts dataset
resource "google_bigquery_dataset_iam_member" "nops_committed_use_discounts" {
  count      = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" && var.bigquery_committed_use_discounts_dataset_id != "" ? 1 : 0
  project    = local.committed_use_discounts_project_id
  dataset_id = local.committed_use_discounts_dataset_id_only
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

