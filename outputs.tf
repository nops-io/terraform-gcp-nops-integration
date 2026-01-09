# API Enablement Outputs
output "billing_export_project_id" {
  description = "The Billing Export Project ID where APIs are enabled"
  value       = var.billing_export_project_id
}

output "enabled_apis_summary" {
  description = "Summary of enabled APIs in the billing export project"
  value = {
    cloud_asset_api_enabled          = [var.billing_export_project_id]
    cloud_billing_api_enabled        = [var.billing_export_project_id]
    recommender_api_enabled          = [var.billing_export_project_id]
    bigquery_reservation_api_enabled = var.enable_bigquery_reservation_api ? [var.billing_export_project_id] : []
  }
}

# Organization IAM Outputs
output "nops_iam_roles_granted" {
  description = "List of organization-level IAM roles granted to the nOps service account"
  value = var.grant_nops_iam_roles && var.nops_service_account_email != "" ? [
    "roles/cloudasset.viewer",
    "roles/browser",
    "roles/recommender.viewer",
    "roles/logging.viewer",
    "roles/compute.viewer",
    "roles/container.viewer",
    "roles/cloudsql.viewer",
    "roles/run.viewer"
  ] : []
}

# Billing Account IAM Outputs
output "nops_billing_iam_roles_granted" {
  description = "List of billing account-level IAM roles granted to the nOps service account"
  value = var.grant_nops_billing_iam_roles && var.nops_service_account_email != "" && var.billing_account_id != "" ? [
    "roles/billing.viewer"
  ] : []
}

# Project IAM Outputs
output "nops_project_iam_roles_granted" {
  description = "List of project-level IAM roles granted to the nOps service account on the billing exports project"
  value = var.grant_nops_project_iam_roles && var.nops_service_account_email != "" && var.billing_export_project_id != "" ? [
    "roles/serviceusage.serviceUsageConsumer"
  ] : []
}

