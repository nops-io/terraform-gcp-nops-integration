# Grant billing account-level IAM roles to nOps service account
# This role provides access to view billing information for cost analysis
resource "google_billing_account_iam_member" "nops_billing_viewer" {
  for_each           = var.grant_nops_billing_iam_roles && var.nops_service_account_email != "" ? local.billing_accounts_map : {}
  billing_account_id = each.value.billing_account_id
  role               = "roles/billing.viewer"
  member             = "serviceAccount:${var.nops_service_account_email}"
}

