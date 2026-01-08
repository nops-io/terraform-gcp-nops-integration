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

# Module invocation for enabling GCP APIs
module "enable_gcp_apis" {
  source = "../.."  # Adjust path based on your setup
  
  organization_id            = "123456789012"  # Replace with your GCP Organization ID
  central_ingestion_project_id = "my-central-project-id"  # Replace with your central project ID
  
  # All APIs are enabled by default:
  # - Cloud Asset API (Central Ingestion Project)
  # - Cloud Billing API (Central Ingestion Project)
  # - Recommender API (all projects)
  # - BigQuery Reservation API (all projects)
  # - Cloud Run Admin API (all projects)
  # - Cloud SQL Admin API (all projects)
  
  # To customize, you can override defaults:
  # enable_cloud_asset_api = false
  # enable_bigquery_reservation_api = false
  # enable_cloud_run_admin_api = false
  # enable_cloud_sql_admin_api = false
  
  # Disable IAM role granting for this module invocation (handled separately below)
  grant_nops_iam_roles = false
  
  disable_apis_on_destroy = false
}

# Module invocation for granting organization-level IAM roles
module "grant_nops_iam_roles" {
  source = "../.."  # Same module, different configuration
  
  organization_id = "123456789012"  # Must match the organization ID above
  
  # Central ingestion project ID is not required for IAM roles, but must be provided
  # (it won't be used when grant_nops_iam_roles is true and enable_*_api vars are false)
  central_ingestion_project_id = "my-central-project-id"
  
  # Disable all API enablement for this module invocation (only granting IAM roles)
  enable_cloud_asset_api = false
  enable_cloud_billing_api = false
  enable_recommender_api = false
  enable_bigquery_reservation_api = false
  enable_cloud_run_admin_api = false
  enable_cloud_sql_admin_api = false
  
  # Grant IAM roles to nOps service account
  nops_service_account_email = "your-nops-sa@project.iam.gserviceaccount.com"
  grant_nops_iam_roles = true
  
  disable_apis_on_destroy = false  # Not applicable when APIs are disabled
}

# Outputs for API enablement
output "api_enablement_summary" {
  value = module.enable_gcp_apis.enabled_apis_summary
}

output "total_projects" {
  value = module.enable_gcp_apis.total_projects
}

# Outputs for IAM roles
output "nops_iam_roles_granted" {
  value = module.grant_nops_iam_roles.nops_iam_roles_granted
}

