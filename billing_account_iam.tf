# Grant billing account-level IAM roles to nOps service account
# This role provides access to view billing information for cost analysis
resource "google_billing_account_iam_member" "nops_billing_viewer" {
  count              = var.grant_nops_billing_iam_roles && var.nops_service_account_email != "" && var.billing_account_id != "" ? 1 : 0
  billing_account_id = var.billing_account_id
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${var.nops_service_account_email}"
}

