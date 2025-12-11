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
    container_api_enabled = [for project_id, project in local.gke_projects : project_id]
    bigquery_reservation_api_enabled = var.enable_bigquery_reservation_api ? [for project_id, project in local.all_projects : project_id] : []
  }
}

output "total_projects" {
  description = "Total number of projects in the organization"
  value       = length(local.all_projects)
}

output "gke_projects_count" {
  description = "Number of projects where GKE API will be enabled"
  value       = length(local.gke_projects)
}

