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

module "enable_gcp_apis" {
  source = "../.."  # Adjust path based on your setup
  
  organization_id            = "123456789012"  # Replace with your GCP Organization ID
  central_ingestion_project_id = "my-central-project-id"  # Replace with your central project ID
  
  # All APIs are enabled by default:
  # - Cloud Asset API (Central Ingestion Project)
  # - Cloud Billing API (Central Ingestion Project)
  # - Recommender API (all projects)
  # - BigQuery Reservation API (all projects)
  # - Kubernetes Engine API (all projects by default)
  
  # To customize, you can override defaults:
  # enable_cloud_asset_api = false
  # enable_bigquery_reservation_api = false
  # enable_gke_apis_for_all_projects = false
  # target_gke_project_ids = ["gke-project-1", "gke-project-2"]
  
  disable_apis_on_destroy = false
}

output "api_enablement_summary" {
  value = module.enable_gcp_apis.enabled_apis_summary
}

output "total_projects" {
  value = module.enable_gcp_apis.total_projects
}

