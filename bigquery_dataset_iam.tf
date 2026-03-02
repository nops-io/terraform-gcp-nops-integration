# Grant BigQuery dataset-level IAM roles to nOps service account
# BigQuery Data Viewer role on each distinct billing export dataset (deduped across billing accounts)
resource "google_bigquery_dataset_iam_member" "nops_dataset_viewer" {
  for_each   = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" ? local.datasets_for_iam : {}
  project    = each.value.project_id
  dataset_id = each.value.dataset_id_only
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

