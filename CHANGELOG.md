# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2024-12-19

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

