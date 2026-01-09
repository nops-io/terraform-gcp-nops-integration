variable "organization_id" {
  description = "The GCP Organization ID where projects are located. Required for API enablement and organization-level IAM roles"
  type        = string
}

variable "central_ingestion_project_id" {
  description = "The project ID for the Central Ingestion Project where Cloud Asset and Cloud Billing APIs will be enabled. Required for API enablement"
  type        = string
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

variable "billing_account_id" {
  description = "The GCP Billing Account ID to grant billing viewer role. Required if grant_nops_billing_iam_roles is true"
  type        = string
  default     = ""
}

variable "grant_nops_billing_iam_roles" {
  description = "Whether to grant billing account-level IAM roles (billing.viewer) to the nOps service account"
  type        = bool
  default     = true
}

variable "enable_bigquery_reservation_api" {
  description = "Enable BigQuery Reservation API in all projects. Only required if using flat-rate or reservation-based BigQuery pricing (for capacity commitments). Most customers use on-demand pricing and can skip this."
  type        = bool
  default     = false
}

