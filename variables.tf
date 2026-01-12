variable "organization_id" {
  description = "The GCP Organization ID where projects are located. Required for organization-level IAM roles"
  type        = string
}

variable "billing_account_id" {
  description = "The GCP Billing Account ID. Used for billing account-level IAM roles only"
  type        = string
}

variable "billing_export_project_id" {
  description = "The GCP Project ID where billing exports are configured. Used for API enablement and project-level IAM roles"
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


variable "grant_nops_billing_iam_roles" {
  description = "Whether to grant billing account-level IAM roles (billing.viewer) to the nOps service account"
  type        = bool
  default     = true
}

variable "enable_bigquery_reservation_api" {
  description = "Enable BigQuery Reservation API in the billing export project. Only required if using flat-rate or reservation-based BigQuery pricing (for capacity commitments). Most customers use on-demand pricing and can skip this."
  type        = bool
  default     = false
}

variable "grant_nops_project_iam_roles" {
  description = "Whether to grant project-level IAM roles (Service Usage Consumer) to the nOps service account on the billing exports project"
  type        = bool
  default     = true
}

variable "bigquery_detailed_usage_cost_dataset_id" {
  description = "The BigQuery Dataset ID for Detailed Usage Cost export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true"
  type        = string
  default     = ""
}

variable "bigquery_pricing_dataset_id" {
  description = "The BigQuery Dataset ID for Pricing Export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true"
  type        = string
  default     = ""
}

variable "bigquery_committed_use_discounts_dataset_id" {
  description = "The BigQuery Dataset ID for Committed Use Discounts Export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true"
  type        = string
  default     = ""
}

variable "grant_nops_bigquery_dataset_iam_roles" {
  description = "Whether to grant BigQuery dataset-level IAM roles (bigquery.dataViewer) to the nOps service account on billing export datasets"
  type        = bool
  default     = true
}

