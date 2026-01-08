output "central_ingestion_project_id" {
  description = "The Central Ingestion Project ID"
  value       = var.central_ingestion_project_id
}

output "enabled_apis_summary" {
  description = "Summary of enabled APIs by project"
  value = {
    cloud_asset_api_enabled = var.enable_cloud_asset_api ? [var.central_ingestion_project_id] : []
    cloud_billing_api_enabled = var.enable_cloud_billing_api ? [var.central_ingestion_project_id] : []
    recommender_api_enabled = var.enable_recommender_api ? [for project_id, project in local.all_projects : project_id] : []
    bigquery_reservation_api_enabled = var.enable_bigquery_reservation_api ? [for project_id, project in local.all_projects : project_id] : []
    cloud_run_admin_api_enabled = var.enable_cloud_run_admin_api ? [for project_id, project in local.all_projects : project_id] : []
    cloud_sql_admin_api_enabled = var.enable_cloud_sql_admin_api ? [for project_id, project in local.all_projects : project_id] : []
  }
}

output "total_projects" {
  description = "Total number of projects in the organization"
  value       = length(local.all_projects)
}

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

