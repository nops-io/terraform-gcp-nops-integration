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

variable "disable_apis_on_destroy" {
  description = "Whether to disable APIs when the Terraform resource is destroyed"
  type        = bool
  default     = false
}

variable "nops_service_account_email" {
  description = "Email address of the nOps service account to grant required IAM roles. If not provided, IAM roles will not be granted"
  type        = string
  default     = ""
}

variable "grant_nops_iam_roles" {
  description = "Whether to grant organization-level IAM roles to the nOps service account"
  type        = bool
  default     = true
}

