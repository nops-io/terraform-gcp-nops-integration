terraform {
  required_version = ">= 1.0"
}

# Extract project IDs and dataset IDs from BigQuery dataset ID strings
# Dataset IDs can be in format "project_id:dataset_id" or just "dataset_id"
locals {
  # Detailed Usage Cost dataset
  detailed_usage_cost_parts = var.bigquery_detailed_usage_cost_dataset_id != "" ? split(":", var.bigquery_detailed_usage_cost_dataset_id) : []
  detailed_usage_cost_project_id = var.bigquery_detailed_usage_cost_dataset_id != "" ? (
    length(local.detailed_usage_cost_parts) > 1 ? local.detailed_usage_cost_parts[0] : var.billing_export_project_id
  ) : var.billing_export_project_id
  detailed_usage_cost_dataset_id_only = var.bigquery_detailed_usage_cost_dataset_id != "" ? (
    length(local.detailed_usage_cost_parts) > 1 ? local.detailed_usage_cost_parts[1] : var.bigquery_detailed_usage_cost_dataset_id
  ) : ""

  # Pricing dataset
  pricing_parts = var.bigquery_pricing_dataset_id != "" ? split(":", var.bigquery_pricing_dataset_id) : []
  pricing_project_id = var.bigquery_pricing_dataset_id != "" ? (
    length(local.pricing_parts) > 1 ? local.pricing_parts[0] : var.billing_export_project_id
  ) : var.billing_export_project_id
  pricing_dataset_id_only = var.bigquery_pricing_dataset_id != "" ? (
    length(local.pricing_parts) > 1 ? local.pricing_parts[1] : var.bigquery_pricing_dataset_id
  ) : ""

  # Committed Use Discounts dataset
  committed_use_discounts_parts = var.bigquery_committed_use_discounts_dataset_id != "" ? split(":", var.bigquery_committed_use_discounts_dataset_id) : []
  committed_use_discounts_project_id = var.bigquery_committed_use_discounts_dataset_id != "" ? (
    length(local.committed_use_discounts_parts) > 1 ? local.committed_use_discounts_parts[0] : var.billing_export_project_id
  ) : var.billing_export_project_id
  committed_use_discounts_dataset_id_only = var.bigquery_committed_use_discounts_dataset_id != "" ? (
    length(local.committed_use_discounts_parts) > 1 ? local.committed_use_discounts_parts[1] : var.bigquery_committed_use_discounts_dataset_id
  ) : ""
}

