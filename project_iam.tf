# Grant project-level IAM roles to nOps service account
# Service Usage Consumer role on billing exports project
resource "google_project_iam_member" "nops_service_usage_consumer" {
  count   = var.grant_nops_project_iam_roles && var.nops_service_account_email != "" && var.billing_account_id != "" ? 1 : 0
  project = var.billing_account_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${var.nops_service_account_email}"
}

