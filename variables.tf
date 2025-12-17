variable "organization_id" {
  description = "The GCP Organization ID where projects are located"
  type        = string
}

variable "central_ingestion_project_id" {
  description = "The project ID for the Central Ingestion Project where Cloud Asset and Cloud Billing APIs will be enabled"
  type        = string
}

variable "enable_cloud_asset_api" {
  description = "Enable Cloud Asset API in the Central Ingestion Project"
  type        = bool
  default     = true
}

variable "enable_cloud_billing_api" {
  description = "Enable Cloud Billing API in the Central Ingestion Project"
  type        = bool
  default     = true
}

variable "enable_recommender_api" {
  description = "Enable Recommender API in all projects (scoped to billing account)"
  type        = bool
  default     = true
}

variable "enable_bigquery_reservation_api" {
  description = "Enable BigQuery Reservation API"
  type        = bool
  default     = true
}

variable "enable_cloud_run_admin_api" {
  description = "Enable Cloud Run Admin API in all projects"
  type        = bool
  default     = true
}

variable "enable_cloud_sql_admin_api" {
  description = "Enable Cloud SQL Admin API in all projects"
  type        = bool
  default     = true
}

variable "target_gke_project_ids" {
  description = "List of specific project IDs where GKE APIs should be enabled. Used when enable_gke_apis_for_all_projects is false"
  type        = list(string)
  default     = []
}

variable "enable_gke_apis_for_all_projects" {
  description = "If true, enable GKE APIs for all projects in the organization. If false, only enable for projects in target_gke_project_ids"
  type        = bool
  default     = true
}

variable "auto_detect_gke_projects" {
  description = "Automatically detect projects with GKE enabled (requires additional permissions). If false, only use target_gke_project_ids"
  type        = bool
  default     = false
}

variable "disable_apis_on_destroy" {
  description = "Whether to disable APIs when the Terraform resource is destroyed"
  type        = bool
  default     = false
}

