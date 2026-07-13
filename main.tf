terraform {
  required_version = ">= 1.0"
}

# Billing accounts keyed by billing_account_id for stable for_each
locals {
  billing_accounts_map = { for b in var.billing_accounts : b.billing_account_id => b }

  # Distinct billing export project IDs (one project can serve multiple billing accounts)
  billing_export_project_ids = toset([for b in var.billing_accounts : b.billing_export_project_id])

  # Parse all BigQuery dataset IDs from all billing accounts. Supported formats:
  #   "dataset_id"                       - dataset-level grant, project defaults to billing_export_project_id
  #   "project_id:dataset_id"            - dataset-level grant
  #   "dataset_id.table_id"              - table/view-level grant, project defaults to billing_export_project_id
  #   "project_id:dataset_id.table_id"   - table/view-level grant
  # Multiple dataset types (e.g. detailed_usage_cost and pricing) can point to the same target; dedupe so each dataset/table is granted once.
  _dataset_entries = flatten([
    for b in var.billing_accounts : [
      for name, did in {
        detailed_usage_cost = b.bigquery_detailed_usage_cost_dataset_id
        pricing             = b.bigquery_pricing_dataset_id
        cuds                = b.bigquery_committed_use_discounts_dataset_id
        } : {
        project_id      = length(split(":", did)) > 1 ? split(":", did)[0] : b.billing_export_project_id
        dataset_id_only = split(".", length(split(":", did)) > 1 ? split(":", did)[1] : did)[0]
        table_id        = length(split(".", did)) > 1 ? split(".", did)[1] : ""
      } if did != ""
    ]
  ])

  # Dataset-level grants (entries without a table part), keyed by "project_id:dataset_id".
  # Grouped by key with first value taken (duplicate keys carry identical values).
  datasets_for_iam = {
    for k, v in {
      for e in local._dataset_entries :
      "${e.project_id}:${e.dataset_id_only}" => { project_id = e.project_id, dataset_id_only = e.dataset_id_only }...
      if e.table_id == ""
    } : k => v[0]
  }

  # Table/view-level grants (entries with a table part), keyed by "project_id:dataset_id.table_id"
  tables_for_iam = {
    for k, v in {
      for e in local._dataset_entries :
      "${e.project_id}:${e.dataset_id_only}.${e.table_id}" => { project_id = e.project_id, dataset_id_only = e.dataset_id_only, table_id = e.table_id }...
      if e.table_id != ""
    } : k => v[0]
  }
}

