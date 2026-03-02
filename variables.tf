variable "organization_id" {
  description = "The GCP Organization ID where projects are located. Required for organization-level IAM roles"
  type        = string
}

variable "billing_accounts" {
  description = "List of billing account configs. One entry per billing account; each can use the same or different billing export projects."
  type = list(object({
    billing_account_id                          = string
    billing_export_project_id                   = string
    bigquery_detailed_usage_cost_dataset_id     = optional(string, "")
    bigquery_pricing_dataset_id                 = optional(string, "")
    bigquery_committed_use_discounts_dataset_id = optional(string, "")
  }))

  validation {
    condition     = length(var.billing_accounts) > 0
    error_message = "billing_accounts must contain at least one entry."
  }

  validation {
    condition     = length(var.billing_accounts) == length(distinct([for b in var.billing_accounts : b.billing_account_id]))
    error_message = "Each billing_account_id in billing_accounts must be unique."
  }
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

variable "grant_nops_bigquery_dataset_iam_roles" {
  description = "Whether to grant BigQuery dataset-level IAM roles (bigquery.dataViewer) to the nOps service account on billing export datasets"
  type        = bool
  default     = true
}

variable "enable_domain_restricted_sharing" {
  description = "Whether to configure domain restricted sharing org policy to allow the nOps organization. Required for customers with domain restricted sharing enabled"
  type        = bool
  default     = false
}

variable "nops_customer_id" {
  description = "The nOps Google Workspace Customer ID. Required when enable_domain_restricted_sharing is true. Can be found in nOps → Organization Settings → GCP Integration"
  type        = string
  default     = ""
}

