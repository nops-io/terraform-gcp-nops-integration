# Grant BigQuery dataset-level IAM roles to nOps service account
# BigQuery Data Viewer role on each distinct billing export dataset (deduped across billing accounts).
# Dataset-level grants are inherited by all tables and views in the dataset.
resource "google_bigquery_dataset_iam_member" "nops_dataset_viewer" {
  for_each   = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" ? local.datasets_for_iam : {}
  project    = each.value.project_id
  dataset_id = each.value.dataset_id_only
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

# Grant BigQuery table/view-level IAM roles to nOps service account
# Used when a dataset ID is provided with a table suffix ("dataset_id.table_id"), granting
# BigQuery Data Viewer only on that specific table or view instead of the whole dataset.
resource "google_bigquery_table_iam_member" "nops_table_viewer" {
  for_each   = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" ? local.tables_for_iam : {}
  project    = each.value.project_id
  dataset_id = each.value.dataset_id_only
  table_id   = each.value.table_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${var.nops_service_account_email}"
}

