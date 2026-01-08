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

# Simple module invocation - enables all APIs and grants all IAM roles
# All APIs are automatically enabled:
# - Cloud Asset API (Central Ingestion Project)
# - Cloud Billing API (Central Ingestion Project)
# - Recommender API (all projects)
# - BigQuery Reservation API (all projects)
# - Cloud Run Admin API (all projects)
# - Cloud SQL Admin API (all projects)
#
# All IAM roles are automatically granted (defaults to true):
# - Organization-level IAM roles (requires nops_service_account_email)
# - Billing account-level IAM roles (requires nops_service_account_email and billing_account_id)
module "nops_gcp_integration" {
  source = "../.."  # Adjust path based on your setup
  
  # Required: Organization and project information
  organization_id            = "123456789012"  # Replace with your GCP Organization ID
  central_ingestion_project_id = "my-central-project-id"  # Replace with your central project ID
  
  # Required: nOps service account information for IAM roles
  nops_service_account_email = "your-nops-sa@project.iam.gserviceaccount.com"
  billing_account_id = "XXXXXX-XXXXXX-XXXXXX"  # Replace with your Billing Account ID
  
  # Optional: All IAM roles are granted by default (set to false to disable)
  # grant_nops_iam_roles = true         # Organization-level roles (default: true)
  # grant_nops_billing_iam_roles = true # Billing account roles (default: true)
  
  # Optional: Disable APIs when module is destroyed (default: false)
  # disable_apis_on_destroy = false
}

# Outputs
output "api_enablement_summary" {
  description = "Summary of enabled APIs by project"
  value = module.nops_gcp_integration.enabled_apis_summary
}

output "total_projects" {
  description = "Total number of projects in the organization"
  value = module.nops_gcp_integration.total_projects
}

output "nops_iam_roles_granted" {
  description = "List of organization-level IAM roles granted"
  value = module.nops_gcp_integration.nops_iam_roles_granted
}

output "nops_billing_iam_roles_granted" {
  description = "List of billing account-level IAM roles granted"
  value = module.nops_gcp_integration.nops_billing_iam_roles_granted
}

