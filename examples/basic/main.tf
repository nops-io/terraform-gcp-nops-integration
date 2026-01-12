terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  # Option 1: Use Application Default Credentials (recommended)
  # Run: gcloud auth application-default login

  # Option 2: Use service account key file
  # credentials = file("path/to/service-account-key.json")

  # Option 3: Use environment variable
  # export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
}

# Simple module invocation - enables all required APIs and grants all IAM roles
# Required APIs are automatically enabled in the billing export project:
# - Cloud Asset API
# - Cloud Billing API
# - Recommender API
#
# Optional APIs (disabled by default):
# - BigQuery Reservation API (only if using flat-rate/reservation BigQuery pricing)
#   enable_bigquery_reservation_api = true  # Set to true if needed
#
# All IAM roles are automatically granted (defaults to true):
# - Organization-level IAM roles (requires nops_service_account_email)
# - Billing account-level IAM roles (requires nops_service_account_email and billing_account_id)
# - Project-level IAM roles (requires nops_service_account_email and billing_export_project_id)
# - BigQuery dataset-level IAM roles (requires nops_service_account_email and BigQuery dataset IDs)
module "nops_gcp_integration" {
  source = "../.." # Adjust path based on your setup

  # Required: Organization, billing account, and billing export project information
  organization_id           = "123456789012"                # Replace with your GCP Organization ID
  billing_account_id        = "XXXXXX-XXXXXX-XXXXXX"        # Replace with your Billing Account ID
  billing_export_project_id = "your-billing-export-project" # Replace with your Billing Export Project ID

  # Required: nOps service account information for IAM roles
  nops_service_account_email = "your-nops-sa@project.iam.gserviceaccount.com"

  # Required: BigQuery dataset IDs for billing exports
  bigquery_detailed_usage_cost_dataset_id     = "your-project:detailed_usage_cost_dataset"     # Replace with your Detailed Usage Cost dataset ID
  bigquery_pricing_dataset_id                 = "your-project:pricing_dataset"                 # Replace with your Pricing Export dataset ID
  bigquery_committed_use_discounts_dataset_id = "your-project:committed_use_discounts_dataset" # Replace with your Committed Use Discounts dataset ID

  # Optional: Enable BigQuery Reservation API (only if using flat-rate/reservation pricing)
  # enable_bigquery_reservation_api = false  # Default: false (most customers use on-demand pricing)

  # Optional: All IAM roles are granted by default (set to false to disable)
  # grant_nops_iam_roles = true         # Organization-level roles (default: true)
  # grant_nops_billing_iam_roles = true # Billing account roles (default: true)
  # grant_nops_project_iam_roles = true # Project-level roles (default: true)
  # grant_nops_bigquery_dataset_iam_roles = true # BigQuery dataset roles (default: true)

  # Optional: Disable APIs when module is destroyed (default: false)
  # disable_apis_on_destroy = false
}

# Outputs
output "api_enablement_summary" {
  description = "Summary of enabled APIs in the billing export project"
  value       = module.nops_gcp_integration.enabled_apis_summary
}

output "billing_account_id" {
  description = "The billing account ID used for billing account-level IAM roles"
  value       = module.nops_gcp_integration.billing_account_id
}

output "billing_export_project_id" {
  description = "The project ID where APIs are enabled"
  value       = module.nops_gcp_integration.billing_export_project_id
}

output "nops_iam_roles_granted" {
  description = "List of organization-level IAM roles granted"
  value       = module.nops_gcp_integration.nops_iam_roles_granted
}

output "nops_billing_iam_roles_granted" {
  description = "List of billing account-level IAM roles granted"
  value       = module.nops_gcp_integration.nops_billing_iam_roles_granted
}

output "nops_project_iam_roles_granted" {
  description = "List of project-level IAM roles granted on billing exports project"
  value       = module.nops_gcp_integration.nops_project_iam_roles_granted
}

output "nops_bigquery_dataset_iam_roles_granted" {
  description = "List of BigQuery dataset-level IAM roles granted on billing export datasets"
  value       = module.nops_gcp_integration.nops_bigquery_dataset_iam_roles_granted
}

