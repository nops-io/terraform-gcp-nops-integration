# GCP nOps Integration Terraform Module

This Terraform/OpenTofu module simplifies the integration of nOps with your GCP organization by automatically:
- **Enabling all required GCP APIs** in your billing export project
- **Granting organization-level IAM roles** to your nOps service account
- **Granting billing account-level IAM roles** to your nOps service account
- **Granting project-level IAM roles** on your billing exports project
- **Granting BigQuery dataset-level IAM roles** on your billing export datasets

With just 7 required variables, you can get up and running quickly. All APIs are always enabled, and all IAM roles are granted by default for the simplest possible experience.

## Module Structure

The module code is organized into separate files:
- **`apis.tf`** - Contains all GCP API enablement resources
- **`organization_iam.tf`** - Contains all organization-level IAM role resources
- **`billing_account_iam.tf`** - Contains all billing account-level IAM role resources
- **`project_iam.tf`** - Contains all project-level IAM role resources
- **`bigquery_dataset_iam.tf`** - Contains all BigQuery dataset-level IAM role resources
- **`main.tf`** - Contains shared Terraform configuration

## Overview

This module automatically enables the following APIs in your billing export project:

**Required APIs (always enabled):**

| API Service | API Service ID | Scope |
|------------|----------------|-------|
| Cloud Asset API | `cloudasset.googleapis.com` | Billing Export Project |
| Cloud Billing API | `cloudbilling.googleapis.com` | Billing Export Project |
| Recommender API | `recommender.googleapis.com` | Billing Export Project |

**Optional APIs:**

| API Service | API Service ID | When Required |
|------------|----------------|---------------|
| BigQuery Reservation API | `bigqueryreservation.googleapis.com` | Only if using flat-rate/reservation BigQuery pricing (for capacity commitments) |

**Note:** BigQuery Reservation API is disabled by default. Most customers use on-demand BigQuery pricing and can skip this. Only enable it if you use flat-rate or reservation-based BigQuery pricing.

## Prerequisites

- [OpenTofu](https://opentofu.org/) or [Terraform](https://www.terraform.io/) installed (>= 1.0)
- **Billing must be enabled** for the billing export project
- Google Cloud credentials with the following permissions:
  - `serviceusage.services.enable` - to enable APIs in the billing export project
  - `serviceusage.services.get` - to check API status
  - Project-level admin role on the billing export project
  - Organization-level admin role (for organization-level IAM roles)

## Installation

### Using OpenTofu

1. **Install OpenTofu** (if not already installed):

   ```bash
   # macOS
   brew install opentofu

   # Linux
   wget https://github.com/opentofu/opentofu/releases/download/v1.6.0/tofu_1.6.0_linux_amd64.zip
   unzip tofu_1.6.0_linux_amd64.zip
   sudo mv tofu /usr/local/bin/

   # Or download from: https://opentofu.org/docs/intro/install/
   ```

2. **Clone or download this module**:

   ```bash
   git clone <repository-url>
   cd nops-gcp-module
   ```

## Usage

### Quick Start - Single Module Invocation

The simplest way to use this module is with a single invocation that enables all APIs and grants all IAM roles:

```hcl
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
  source = "./nops-gcp-module"  # or use git URL
  
  # Required: Organization and project information
  organization_id        = "123456789012"  # Replace with your GCP Organization ID
  billing_export_project_id = "your-billing-export-project"  # Replace with your billing export project ID
  
  # Required: nOps service account information for IAM roles
  nops_service_account_email = "your-nops-sa@project.iam.gserviceaccount.com"
  billing_account_id = "XXXXXX-XXXXXX-XXXXXX"  # Replace with your Billing Account ID
  
  # Required: BigQuery dataset IDs for billing exports
  bigquery_detailed_usage_cost_dataset_id = "your-project:detailed_usage_cost_dataset"  # Replace with your Detailed Usage Cost dataset ID
  bigquery_pricing_dataset_id = "your-project:pricing_dataset"  # Replace with your Pricing Export dataset ID
  bigquery_committed_use_discounts_dataset_id = "your-project:committed_use_discounts_dataset"  # Replace with your Committed Use Discounts dataset ID
  
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
  value = module.nops_gcp_integration.enabled_apis_summary
}

output "billing_export_project_id" {
  description = "The billing export project ID where APIs are enabled"
  value = module.nops_gcp_integration.billing_export_project_id
}

output "nops_iam_roles_granted" {
  description = "List of organization-level IAM roles granted"
  value = module.nops_gcp_integration.nops_iam_roles_granted
}

output "nops_billing_iam_roles_granted" {
  description = "List of billing account-level IAM roles granted"
  value = module.nops_gcp_integration.nops_billing_iam_roles_granted
}

output "nops_project_iam_roles_granted" {
  description = "List of project-level IAM roles granted on billing exports project"
  value = module.nops_gcp_integration.nops_project_iam_roles_granted
}
```

That's it! With just 7 required variables, this module will:
- ✅ Enable all required GCP APIs in your billing export project
- ✅ Grant organization-level IAM roles to your nOps service account
- ✅ Grant billing account-level IAM roles to your nOps service account
- ✅ Grant project-level IAM roles on your billing exports project
- ✅ Grant BigQuery dataset-level IAM roles on your billing export datasets
```

### What Gets Enabled and Granted

**Required APIs Enabled (automatically, no configuration needed):**
- Cloud Asset API (Billing Export Project)
- Cloud Billing API (Billing Export Project)
- Recommender API (Billing Export Project)

**Optional APIs:**
- BigQuery Reservation API (disabled by default) - Only enable if using flat-rate or reservation-based BigQuery pricing (for capacity commitments). Most customers use on-demand pricing and can skip this.

**Organization-Level IAM Roles Granted (automatically, default: true):**
- `roles/cloudasset.viewer` - To enumerate assets across services for correlation
- `roles/browser` - To enumerate projects and folders
- `roles/recommender.viewer` - To read cost recommendations (e.g., rightsizing, idle resources)
- `roles/logging.viewer` - To read logs for resource analysis
- `roles/compute.viewer` - To read Compute Engine data (CUDs, instances, regions)
- `roles/container.viewer` - To read GKE cluster data
- `roles/cloudsql.viewer` - To read Cloud SQL instances and configurations
- `roles/run.viewer` - To read Cloud Run services and configurations

**Billing Account-Level IAM Roles Granted (automatically, default: true):**
- `roles/billing.viewer` - To view billing information for cost analysis

**Project-Level IAM Roles Granted (automatically, default: true):**
- `roles/serviceusage.serviceUsageConsumer` - To consume services on the billing exports project (required for billing export access)

**BigQuery Dataset-Level IAM Roles Granted (automatically, default: true):**
- `roles/bigquery.dataViewer` on Detailed Usage Cost dataset - To read detailed usage cost data
- `roles/bigquery.dataViewer` on Pricing dataset - To read pricing export data
- `roles/bigquery.dataViewer` on Committed Use Discounts dataset - To read committed use discounts data

### Advanced Usage - Separate Module Invocations

For advanced use cases where you need more control, you can invoke the module multiple times with different configurations. See the [examples directory](examples/) for more details.

### Running with OpenTofu

1. **Initialize OpenTofu**:

   ```bash
   tofu init
   ```

2. **Review the execution plan**:

   ```bash
   tofu plan
   ```

3. **Apply the configuration**:

   ```bash
   tofu apply
   ```

   Review the plan carefully. You'll see output showing:
   - Which APIs will be enabled
   - In which projects they'll be enabled
   - Total number of projects affected

4. **Verify the outputs**:

   ```bash
   tofu output
   ```

## Authentication

### Option 1: Application Default Credentials (Recommended)

```bash
gcloud auth application-default login
```

This will use your user credentials. Make sure you have the necessary permissions.

### Option 2: Service Account Key

1. Create a service account with required permissions
2. Download the JSON key file
3. Set the path in your provider configuration:

```hcl
provider "google" {
  credentials = file("path/to/service-account-key.json")
}
```

Or use environment variable:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
```

### Option 3: Workload Identity (for CI/CD)

If running in GCP (e.g., Cloud Build), use Workload Identity:

```hcl
provider "google" {
  # Credentials will be automatically detected
}
```

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `organization_id` | GCP Organization ID. Required for organization-level IAM roles | `string` | - | yes |
| `billing_export_project_id` | The GCP Project ID that hosts billing exports. Required for API enablement and project-level IAM roles | `string` | - | yes |
| `bigquery_detailed_usage_cost_dataset_id` | The BigQuery Dataset ID for Detailed Usage Cost export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true | `string` | `""` | no |
| `bigquery_pricing_dataset_id` | The BigQuery Dataset ID for Pricing Export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true | `string` | `""` | no |
| `bigquery_committed_use_discounts_dataset_id` | The BigQuery Dataset ID for Committed Use Discounts Export. Format: project_id:dataset_id or dataset_id (if in billing export project). Required if grant_nops_bigquery_dataset_iam_roles is true | `string` | `""` | no |
| `disable_apis_on_destroy` | Disable APIs when destroyed | `bool` | `false` | no |
| `enable_bigquery_reservation_api` | Enable BigQuery Reservation API in the billing export project. Only required if using flat-rate or reservation-based BigQuery pricing (for capacity commitments). Most customers use on-demand pricing and can skip this. | `bool` | `false` | no |
| `nops_service_account_email` | Email address of the nOps service account to grant required IAM roles | `string` | `""` | no |
| `grant_nops_iam_roles` | Whether to grant organization-level IAM roles to the nOps service account | `bool` | `true` | no |
| `billing_account_id` | The GCP Billing Account ID to grant billing viewer role. Required if grant_nops_billing_iam_roles is true | `string` | `""` | no |
| `grant_nops_billing_iam_roles` | Whether to grant billing account-level IAM roles (billing.viewer) to the nOps service account | `bool` | `true` | no |
| `grant_nops_project_iam_roles` | Whether to grant project-level IAM roles (Service Usage Consumer) to the nOps service account on the billing exports project | `bool` | `true` | no |
| `grant_nops_bigquery_dataset_iam_roles` | Whether to grant BigQuery dataset-level IAM roles (bigquery.dataViewer) to the nOps service account on billing export datasets | `bool` | `true` | no |

## Outputs

| Output | Description |
|--------|-------------|
| `billing_export_project_id` | The Billing Export Project ID where APIs are enabled |
| `enabled_apis_summary` | Summary of enabled APIs in the billing export project |
| `nops_iam_roles_granted` | List of organization-level IAM roles granted to the nOps service account |
| `nops_billing_iam_roles_granted` | List of billing account-level IAM roles granted to the nOps service account |
| `nops_project_iam_roles_granted` | List of project-level IAM roles granted to the nOps service account on the billing exports project |
| `nops_bigquery_dataset_iam_roles_granted` | List of BigQuery dataset-level IAM roles granted to the nOps service account on billing export datasets |

## Finding Your Organization ID

To find your GCP Organization ID:

```bash
gcloud organizations list
```

Or via the GCP Console:
1. Go to [GCP Console](https://console.cloud.google.com/)
2. Select your organization
3. The Organization ID is shown in the URL or organization details

## Finding Your Billing Export Project ID

The `billing_export_project_id` is the GCP project ID where your billing exports are hosted. This is the project that contains your BigQuery dataset for billing export data. All required APIs will be enabled in this project.

### What is a Billing Export Project?

A Billing Export Project is the GCP project that hosts your billing export data. This project:
- Contains your BigQuery dataset for billing export data
- Is where all required APIs (Cloud Asset, Cloud Billing, Recommender) will be enabled
- Must have billing enabled

This project should be:
- An existing project in your organization (this module does not create projects)
- A project you have administrative access to
- The project where your billing exports are configured

### How to Find Your Project ID

**Option 1: Using gcloud CLI**

List all projects accessible to you:
```bash
gcloud projects list
```

Example output:
```
PROJECT_ID          NAME                  PROJECT_NUMBER
my-project-id       My Project Name       123456789012
another-project     Another Project       987654321098
```

The value you need is in the `PROJECT_ID` column (the first column), not the `NAME` column.

To get just the project ID for a specific project:
```bash
gcloud config get-value project
```

Or set a project and then get its ID:
```bash
gcloud config set project MY-PROJECT-NAME
gcloud config get-value project
```

**Option 2: Using GCP Console**

1. Go to [GCP Console](https://console.cloud.google.com/)
2. Click on the project selector dropdown at the top of the page
3. The Project ID is displayed in the dropdown list (usually shown in parentheses or as a secondary label)
4. Alternatively:
   - Select your project
   - Navigate to **IAM & Admin** > **Settings**
   - The Project ID is displayed at the top of the settings page
   - Or check the URL: `https://console.cloud.google.com/home/dashboard?project=YOUR-PROJECT-ID`

**Option 3: Using Project Number (if you only know the number)**

If you only have the project number, you can find the project ID:
```bash
gcloud projects describe PROJECT_NUMBER --format="value(projectId)"
```

### Important Notes

- **Use Project ID, not Project Name**: Project IDs are globally unique identifiers (e.g., `my-project-12345`), while Project Names are just labels
- **Project must exist**: This module does not create projects - you must use an existing project
- **Same organization**: The project must be in the same organization specified by `organization_id`
- **Permissions required**: You need `roles/serviceusage.serviceUsageAdmin` or similar permissions on this project to enable APIs
- **Billing must be enabled**: Ensure billing is enabled on the project before running the module

### Example

If your project details are:
- **Project Name**: "Billing Export Project"
- **Project ID**: `billing-export-project-12345`
- **Project Number**: `123456789012`

You would use:
```hcl
billing_export_project_id = "billing-export-project-12345"
```

## Finding Your Billing Account ID

To find your GCP Billing Account ID:

```bash
gcloud billing accounts list
```

Example output:
```
ACCOUNT_ID            NAME                OPEN
012345-6789AB-CDEF01  My Billing Account  True
```

The value you need is in the `ACCOUNT_ID` column (the first column), which typically has the format `XXXXXX-XXXXXX-XXXXXX`.

Or via the GCP Console:
1. Go to [GCP Console Billing](https://console.cloud.google.com/billing)
2. Select your billing account
3. The Billing Account ID is displayed at the top of the billing account details page
4. Or check the URL: `https://console.cloud.google.com/billing/XXXXXX-XXXXXX-XXXXXX`

### Example

If your billing account details are:
- **Billing Account Name**: "My Company Billing Account"
- **Billing Account ID**: `012345-6789AB-CDEF01`

You would use:
```hcl
billing_account_id = "012345-6789AB-CDEF01"
```

**Note:** The billing account ID is required if `grant_nops_billing_iam_roles` is set to `true`.

## Finding Your Billing Export Project ID

The `billing_export_project_id` is the GCP project ID where your billing exports are hosted. This is the project that contains your BigQuery dataset for billing export data.

### How to Find Your Billing Export Project ID

**Option 1: Using gcloud CLI**

List all projects accessible to you:
```bash
gcloud projects list
```

**Option 2: Using GCP Console**

1. Go to [GCP Console Billing](https://console.cloud.google.com/billing)
2. Select your billing account
3. Navigate to **Billing export** in the left menu
4. The project ID hosting the billing export is shown in the export configuration
5. Or check your BigQuery dataset - the project containing the billing export dataset is your billing export project

**Option 3: Check BigQuery Dataset**

If you know your billing export BigQuery dataset:
```bash
gcloud billing projects describe PROJECT_ID
```

### Example

If your billing export project details are:
- **Project Name**: "Billing Export Project"
- **Project ID**: `billing-export-project-12345`

You would use:
```hcl
billing_export_project_id = "billing-export-project-12345"
```

**Note:** The billing export project ID is required if `grant_nops_project_iam_roles` is set to `true`.

## Finding Your BigQuery Dataset IDs

The module requires three BigQuery dataset IDs for billing exports:
- **Detailed Usage Cost dataset** - Contains detailed usage and cost data
- **Pricing dataset** - Contains pricing information
- **Committed Use Discounts dataset** - Contains committed use discount information

### How to Find Your BigQuery Dataset IDs

**Option 1: Using gcloud CLI**

List all datasets in your billing export project:
```bash
gcloud bigquery datasets list --project=YOUR_BILLING_EXPORT_PROJECT_ID
```

Get details for a specific dataset:
```bash
gcloud bigquery datasets describe DATASET_ID --project=YOUR_BILLING_EXPORT_PROJECT_ID
```

**Option 2: Using GCP Console**

1. Go to [BigQuery Console](https://console.cloud.google.com/bigquery)
2. Select your billing export project
3. In the left sidebar, expand your project to see all datasets
4. The dataset ID is shown next to each dataset name
5. For billing exports, look for datasets like:
   - `gcp_billing_export_v1_XXXXXX` (Detailed Usage Cost)
   - `gcp_billing_export_pricing_XXXXXX` (Pricing)
   - `gcp_billing_export_cud_XXXXXX` (Committed Use Discounts)

**Option 3: From Billing Export Configuration**

1. Go to [GCP Console Billing](https://console.cloud.google.com/billing)
2. Select your billing account
3. Navigate to **Billing export** in the left menu
4. The dataset IDs are shown in the export configuration for each export type

### Dataset ID Format

The dataset ID can be provided in two formats:
- **Full format**: `project_id:dataset_id` (e.g., `my-project:gcp_billing_export_v1_123456`)
- **Short format**: `dataset_id` (if the dataset is in the billing export project specified by `billing_export_project_id`)

### Example

If your BigQuery datasets are:
- **Detailed Usage Cost**: `gcp_billing_export_v1_123456` in project `billing-export-project-12345`
- **Pricing**: `gcp_billing_export_pricing_123456` in project `billing-export-project-12345`
- **Committed Use Discounts**: `gcp_billing_export_cud_123456` in project `billing-export-project-12345`

And your `billing_export_project_id` is `billing-export-project-12345`, you can use either:

```hcl
# Full format
bigquery_detailed_usage_cost_dataset_id = "billing-export-project-12345:gcp_billing_export_v1_123456"
bigquery_pricing_dataset_id = "billing-export-project-12345:gcp_billing_export_pricing_123456"
bigquery_committed_use_discounts_dataset_id = "billing-export-project-12345:gcp_billing_export_cud_123456"

# Or short format (if datasets are in billing_export_project_id)
bigquery_detailed_usage_cost_dataset_id = "gcp_billing_export_v1_123456"
bigquery_pricing_dataset_id = "gcp_billing_export_pricing_123456"
bigquery_committed_use_discounts_dataset_id = "gcp_billing_export_cud_123456"
```

**Note:** The BigQuery dataset IDs are required if `grant_nops_bigquery_dataset_iam_roles` is set to `true`.

## Permissions Required

The service account or user running this module needs:

- **Organization Level**:
  - `resourcemanager.organizations.get`
  - `resourcemanager.projects.list`
  - `resourcemanager.organizationIamPolicies.set` (required if granting organization-level IAM roles)

- **Billing Account Level**:
  - `billing.accounts.getIamPolicy` (required to read billing account IAM policy)
  - `billing.accounts.setIamPolicy` (required if granting billing account-level IAM roles)

- **Project Level** (for the billing export project):
  - `serviceusage.services.enable` (required for API enablement)
  - `serviceusage.services.get` (required for API enablement)
  - `serviceusage.services.list` (required for API enablement)
  - `resourcemanager.projects.getIamPolicy` (required to read project IAM policy)
  - `resourcemanager.projects.setIamPolicy` (required if granting project-level IAM roles)
- **BigQuery Dataset Level**:
  - `bigquery.datasets.get` (required to read dataset information)
  - `bigquery.datasets.setIamPolicy` (required if granting BigQuery dataset-level IAM roles)

You can grant these permissions by assigning one of these roles:
- `roles/serviceusage.serviceUsageAdmin` (recommended for API enablement)
- `roles/resourcemanager.organizationAdmin` (required for granting organization-level IAM roles)
- `roles/billing.admin` (required for granting billing account-level IAM roles)
- `roles/resourcemanager.projectIamAdmin` (required for granting project-level IAM roles)
- `roles/owner` (full access)

**Note:** 
- If you're granting organization-level IAM roles to the nOps service account, you need organization-level IAM permissions (`roles/resourcemanager.organizationAdmin` or `roles/owner` at the organization level).
- If you're granting billing account-level IAM roles, you need billing account permissions (`roles/billing.admin` or `roles/owner` on the billing account).
- If you're granting project-level IAM roles, you need project-level IAM permissions (`roles/resourcemanager.projectIamAdmin` or `roles/owner` on the billing export project).

## Troubleshooting

### Error: "Permission denied"

Ensure your credentials have the required permissions listed above.

### Error: "Project not found"

Verify that:
- The `organization_id` is correct
- The `billing_export_project_id` exists and is accessible
- Your credentials have access to the organization and the billing export project

### APIs not enabling

- Check that billing is enabled for the projects
- Verify API enablement permissions
- Some APIs may take a few minutes to fully enable

### OpenTofu vs Terraform

This module is compatible with both OpenTofu and Terraform. Simply replace `tofu` commands with `terraform` if using Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Limitations

- API enablement is asynchronous; the module will wait for enablement to complete

## Support

For issues or questions, please contact nOps Support.


