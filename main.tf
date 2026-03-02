terraform {
  required_version = ">= 1.0"
}

# Billing accounts keyed by billing_account_id for stable for_each
locals {
  billing_accounts_map = { for b in var.billing_accounts : b.billing_account_id => b }

  # Distinct billing export project IDs (one project can serve multiple billing accounts)
  billing_export_project_ids = toset([for b in var.billing_accounts : b.billing_export_project_id])

  # Parse all BigQuery dataset IDs from all billing accounts. Dataset ID can be "project_id:dataset_id" or "dataset_id" (defaults to billing_export_project_id).
  # Multiple dataset types (e.g. detailed_usage_cost and pricing) can point to the same dataset; dedupe by "project_id:dataset_id" so each dataset is granted once.
  _dataset_entries = flatten([
    for b in var.billing_accounts : [
      for name, did in {
        detailed_usage_cost = b.bigquery_detailed_usage_cost_dataset_id
        pricing             = b.bigquery_pricing_dataset_id
        cuds                = b.bigquery_committed_use_discounts_dataset_id
      } : {
        key             = did != "" ? (length(split(":", did)) > 1 ? "${split(":", did)[0]}:${split(":", did)[1]}" : "${b.billing_export_project_id}:${did}") : ""
        project_id      = did != "" ? (length(split(":", did)) > 1 ? split(":", did)[0] : b.billing_export_project_id) : ""
        dataset_id_only = did != "" ? (length(split(":", did)) > 1 ? split(":", did)[1] : did) : ""
      } if did != ""
    ]
  ])
  # Group by key and take first value (same project_id/dataset_id_only for duplicate keys)
  datasets_for_iam = { for k, v in { for e in local._dataset_entries : e.key => { project_id = e.project_id, dataset_id_only = e.dataset_id_only }... } : k => v[0] }
}

