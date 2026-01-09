# Changelog

All notable changes to this project will be documented in this file.

## [2.0.1] - 2026-01-09

### Changed
- updated .gitignore to exclude .DS_Store

### Removed
- removed commited .DS_Store

## [2.0.0] - 2026-01-08

### ⚠️ BREAKING CHANGES

**IMPORTANT**: This version contains breaking changes. Please review the following changes before upgrading:

- **Removed all `enable_*_api` variables** - Required APIs are now always enabled. Remove any `enable_cloud_asset_api`, `enable_cloud_billing_api`, `enable_recommender_api` variables from your configuration.
- **BigQuery Reservation API is now optional** - The BigQuery Reservation API is now disabled by default. Add `enable_bigquery_reservation_api = true` if you use flat-rate or reservation-based BigQuery pricing.
- **Removed GKE API enablement** - Kubernetes Engine API enablement has been removed. Remove `target_gke_project_ids`, `enable_gke_apis_for_all_projects`, and `auto_detect_gke_projects` variables.
- **APIs now only enabled in billing export project** - All APIs (Cloud Asset, Cloud Billing, Recommender, and optional BigQuery Reservation) are now enabled only in the billing export project, not across all projects or in a central ingestion project.
- **Removed `central_ingestion_project_id` variable** - This variable is no longer needed. APIs are enabled using the `billing_account_id` instead.
- **Removed `billing_export_project_id` variable** - This variable has been removed. Use `billing_account_id` for both billing account-level IAM roles and API enablement.
- **Made `billing_account_id` required** - This variable is now required (previously optional) as it's used for billing account-level IAM roles, API enablement, and project-level IAM roles.
- **Removed `google_projects` data source** - The module no longer queries all projects in the organization since APIs are only enabled in the billing export project.
- **Removed `total_projects` output** - This output is no longer available since the module no longer enumerates all projects.

### Added
- Added organization-level IAM role granting for nOps service account
  - Grants 8 organization-level roles: cloudasset.viewer, browser, recommender.viewer, logging.viewer, compute.viewer, container.viewer, cloudsql.viewer, run.viewer
  - Configurable via `grant_nops_iam_roles` variable (default: true)
- Added billing account-level IAM role granting for nOps service account
  - Grants billing.viewer role at billing account level
  - Configurable via `grant_nops_billing_iam_roles` variable (default: true)
  - Requires `billing_account_id` variable
- Added project-level IAM role granting for nOps service account
  - Grants serviceusage.serviceUsageConsumer role on billing exports project
  - Configurable via `grant_nops_project_iam_roles` variable (default: true)
  - Uses `billing_account_id` variable
- Added BigQuery dataset-level IAM role granting for nOps service account
  - Grants bigquery.dataViewer role on three billing export datasets: Detailed Usage Cost, Pricing, and Committed Use Discounts
  - Configurable via `grant_nops_bigquery_dataset_iam_roles` variable (default: true)
  - Requires `bigquery_detailed_usage_cost_dataset_id`, `bigquery_pricing_dataset_id`, and `bigquery_committed_use_discounts_dataset_id` variables

### Changed
- Required APIs are now always enabled (see Breaking Changes above)
  - Cloud Asset API, Cloud Billing API, and Recommender API are always enabled
- BigQuery Reservation API is now optional and disabled by default
  - Only enable if using flat-rate or reservation-based BigQuery pricing (for capacity commitments)
  - Most customers use on-demand pricing and can skip this
  - Controlled via `enable_bigquery_reservation_api` variable (default: false)
- APIs are now enabled only in the billing export project (not across all projects)
  - Cloud Asset API: Enabled in billing export project (previously: Central Ingestion Project)
  - Cloud Billing API: Enabled in billing export project (previously: Central Ingestion Project)
  - Recommender API: Enabled in billing export project (previously: All projects)
  - BigQuery Reservation API: Enabled in billing export project (previously: All projects)
- Simplified module structure - removed `google_projects` data source and related locals
- Separated code into organized files:
  - `apis.tf` - All GCP API enablement resources
  - `organization_iam.tf` - Organization-level IAM role resources
  - `billing_account_iam.tf` - Billing account-level IAM role resources
  - `project_iam.tf` - Project-level IAM role resources
  - `main.tf` - Shared Terraform configuration
- Simplified module invocation - single module call enables everything by default
- Updated examples to show simplest possible usage (4 required variables)
- Updated all documentation to reflect billing export project as the single location for API enablement
- Updated examples to use `billing_account_id` instead of `central_ingestion_project_id` and `billing_export_project_id`
- Updated README to emphasize simplicity and ease of use

### Removed
- Removed `enable_cloud_asset_api`, `enable_cloud_billing_api`, `enable_recommender_api`, `enable_cloud_run_admin_api`, `enable_cloud_sql_admin_api` variables
- Note: `enable_bigquery_reservation_api` variable was added (default: false) to make BigQuery Reservation API optional
- Removed `target_gke_project_ids`, `enable_gke_apis_for_all_projects`, `auto_detect_gke_projects` variables
- Removed GKE API enablement resources and outputs
- Removed Cloud SQL Admin API (`sqladmin.googleapis.com`) enablement - no longer needed for nOps integration
- Removed Cloud Run Admin API (`run.googleapis.com`) enablement - no longer needed for nOps integration
- Removed `central_ingestion_project_id` variable - APIs are now enabled using `billing_account_id`
- Removed `billing_export_project_id` variable - Now using `billing_account_id` for all billing-related operations
- Removed `google_projects` data source - no longer needed since APIs are only enabled in the billing export project
- Removed `total_projects` output - no longer available since the module no longer enumerates all projects

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

