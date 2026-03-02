# API Enablement Outputs
output "billing_account_ids" {
  description = "List of Billing Account IDs used for billing account-level IAM roles"
  value       = [for b in var.billing_accounts : b.billing_account_id]
}

output "billing_export_project_ids" {
  description = "Set of project IDs where APIs are enabled (distinct across billing accounts)"
  value       = local.billing_export_project_ids
}

output "enabled_apis_summary" {
  description = "Summary of enabled APIs per billing export project"
  value = {
    cloud_asset_api_enabled          = local.billing_export_project_ids
    cloud_billing_api_enabled        = local.billing_export_project_ids
    recommender_api_enabled          = local.billing_export_project_ids
    bigquery_reservation_api_enabled = var.enable_bigquery_reservation_api ? local.billing_export_project_ids : []
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
  description = "List of billing account-level IAM roles granted to the nOps service account (one per billing account)"
  value       = var.grant_nops_billing_iam_roles && var.nops_service_account_email != "" ? [for id in keys(local.billing_accounts_map) : "roles/billing.viewer on ${id}"] : []
}

# Project IAM Outputs
output "nops_project_iam_roles_granted" {
  description = "List of project-level IAM roles granted to the nOps service account on each billing exports project"
  value       = var.grant_nops_project_iam_roles && var.nops_service_account_email != "" ? [for p in local.billing_export_project_ids : "roles/serviceusage.serviceUsageConsumer on ${p}"] : []
}

# BigQuery Dataset IAM Outputs
output "nops_bigquery_dataset_iam_roles_granted" {
  description = "List of BigQuery dataset-level IAM roles granted to the nOps service account on billing export datasets"
  value       = var.grant_nops_bigquery_dataset_iam_roles && var.nops_service_account_email != "" ? [for k in keys(local.datasets_for_iam) : "roles/bigquery.dataViewer on ${k}"] : []
}

