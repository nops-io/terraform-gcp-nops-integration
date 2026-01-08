# Grant organization-level IAM roles to nOps service account
# These roles provide fleet-wide visibility for asset enumeration, recommendations, and resource analysis
resource "google_organization_iam_member" "nops_cloudasset_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_browser" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/browser"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_recommender_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/recommender.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_logging_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/logging.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_compute_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/compute.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_container_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/container.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_cloudsql_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/cloudsql.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

resource "google_organization_iam_member" "nops_run_viewer" {
  count  = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? 1 : 0
  org_id = var.organization_id
  role   = "roles/run.viewer"
  member = "serviceAccount:${var.nops_service_account_email}"
}

