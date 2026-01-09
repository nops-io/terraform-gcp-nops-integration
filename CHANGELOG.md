# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-01-08

### ⚠️ BREAKING CHANGES

**IMPORTANT**: This version contains breaking changes. Please review the following changes before upgrading:

- **Removed all `enable_*_api` variables** - All APIs are now always enabled. Remove any `enable_cloud_asset_api`, `enable_cloud_billing_api`, `enable_recommender_api`, `enable_bigquery_reservation_api` variables from your configuration.
- **Removed GKE API enablement** - Kubernetes Engine API enablement has been removed. Remove `target_gke_project_ids`, `enable_gke_apis_for_all_projects`, and `auto_detect_gke_projects` variables.
- **Made `organization_id` and `central_ingestion_project_id` required** - These variables no longer have empty defaults and must be provided.

### Added
- Added organization-level IAM role granting for nOps service account
  - Grants 8 organization-level roles: cloudasset.viewer, browser, recommender.viewer, logging.viewer, compute.viewer, container.viewer, cloudsql.viewer, run.viewer
  - Configurable via `grant_nops_iam_roles` variable (default: true)
- Added billing account-level IAM role granting for nOps service account
  - Grants billing.viewer role at billing account level
  - Configurable via `grant_nops_billing_iam_roles` variable (default: true)
  - Requires `billing_account_id` variable

### Changed
- All APIs are now always enabled (see Breaking Changes above)
  - Cloud Asset API, Cloud Billing API, Recommender API, and BigQuery Reservation API are always enabled
- Separated code into organized files:
  - `apis.tf` - All GCP API enablement resources
  - `organization_iam.tf` - Organization-level IAM role resources
  - `billing_account_iam.tf` - Billing account-level IAM role resources
  - `main.tf` - Shared data sources and local values
- Simplified module invocation - single module call enables everything by default
- Updated examples to show simplest possible usage (4 required variables)
- Updated README to emphasize simplicity and ease of use

### Removed
- Removed `enable_cloud_asset_api`, `enable_cloud_billing_api`, `enable_recommender_api`, `enable_bigquery_reservation_api`, `enable_cloud_run_admin_api`, `enable_cloud_sql_admin_api` variables
- Removed `target_gke_project_ids`, `enable_gke_apis_for_all_projects`, `auto_detect_gke_projects` variables
- Removed GKE API enablement resources and outputs
- Removed Cloud SQL Admin API (`sqladmin.googleapis.com`) enablement - no longer needed for nOps integration
- Removed Cloud Run Admin API (`run.googleapis.com`) enablement - no longer needed for nOps integration

## [1.1.0] - 2025-12-19

### Added
- Added support for Cloud Run Admin API (`run.googleapis.com`)
  - Enabled in all projects by default
  - Configurable via `enable_cloud_run_admin_api` variable
- Added support for Cloud SQL Admin API (`sqladmin.googleapis.com`)
  - Enabled in all projects by default
  - Configurable via `enable_cloud_sql_admin_api` variable
- Updated outputs to include Cloud Run Admin API and Cloud SQL Admin API in the `enabled_apis_summary`

### Changed
- Updated example documentation to reflect new APIs

## [1.0.0] - Initial Release

### Added
- Cloud Asset API support (Central Ingestion Project)
- Cloud Billing API support (Central Ingestion Project)
- Recommender API support (all projects)
- Kubernetes Engine API support (configurable scope)
- BigQuery Reservation API support (all projects)
- Configurable API enablement via variables
- Support for enabling/disabling APIs on destroy
- Comprehensive documentation and examples

