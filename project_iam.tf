# Grant project-level IAM roles to nOps service account
# Service Usage Consumer role on each distinct billing exports project
resource "google_project_iam_member" "nops_service_usage_consumer" {
  for_each = var.grant_nops_project_iam_roles && var.nops_service_account_email != "" ? local.billing_export_project_ids : toset([])
  project  = each.key
  role     = "roles/serviceusage.serviceUsageConsumer"
  member   = "serviceAccount:${var.nops_service_account_email}"
}

