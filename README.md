# GCP API Enablement Terraform Module

This Terraform/OpenTofu module enables specific Google Cloud Platform APIs across all projects in an organization based on different scoping requirements.

## Overview

This module enables the following APIs:

| API Service | API Service ID | Scope |
|------------|----------------|-------|
| Cloud Asset API | `cloudasset.googleapis.com` | Central Ingestion Project |
| Cloud Billing API | `cloudbilling.googleapis.com` | Central Ingestion Project |
| Recommender API | `recommender.googleapis.com` | All projects (scoped to billing account) |
| BigQuery Reservation API | `bigqueryreservation.googleapis.com` | All projects (configurable) |
| Cloud Run Admin API | `run.googleapis.com` | All projects (configurable) |
| Cloud SQL Admin API | `sqladmin.googleapis.com` | All projects (configurable) |

## Prerequisites

- [OpenTofu](https://opentofu.org/) or [Terraform](https://www.terraform.io/) installed (>= 1.0)
- **Billing must be enabled**:
  - **Central Ingestion Project**: Billing must be enabled for the central ingestion project
  - **Other Projects**: Billing is recommended for all projects where APIs will be enabled
- Google Cloud credentials with the following permissions:
  - `resourcemanager.projects.list` - to list all projects in the organization
  - `serviceusage.services.enable` - to enable APIs
  - `serviceusage.services.get` - to check API status
  - Organization-level or project-level admin role

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

### Basic Example

Create a `main.tf` file in your working directory:

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

module "enable_gcp_apis" {
  source = "./nops-gcp-module"  # or use git URL
  
  organization_id            = "123456789012"  # Your GCP Organization ID
  central_ingestion_project_id = "my-central-project-id"
  
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
  
  disable_apis_on_destroy = false  # Set to true if you want APIs disabled when module is destroyed
}
```

### Example with nOps Service Account IAM Roles

This module can automatically grant the required organization-level IAM roles to your nOps service account:

```hcl
module "enable_gcp_apis" {
  source = "./nops-gcp-module"
  
  organization_id            = "123456789012"
  central_ingestion_project_id = "central-ingestion-project"
  
  # Grant IAM roles to nOps service account
  nops_service_account_email = "nops-sa@your-project.iam.gserviceaccount.com"
  grant_nops_iam_roles       = true  # Set to false to skip IAM role granting
}
```

The following organization-level roles will be granted to the nOps service account:
- `roles/cloudasset.viewer` - To enumerate assets across services for correlation
- `roles/browser` - To enumerate projects and folders
- `roles/recommender.viewer` - To read cost recommendations (e.g., rightsizing, idle resources)
- `roles/logging.viewer` - To read logs for resource analysis
- `roles/compute.viewer` - To read Compute Engine data (CUDs, instances, regions)
- `roles/container.viewer` - To read GKE cluster data
- `roles/cloudsql.viewer` - To read Cloud SQL instances and configurations
- `roles/run.viewer` - To read Cloud Run services and configurations

**Note:** If `nops_service_account_email` is not provided or is an empty string, IAM roles will not be granted. Set `grant_nops_iam_roles = false` to disable IAM role granting even if a service account email is provided.

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
| `organization_id` | GCP Organization ID | `string` | - | yes |
| `central_ingestion_project_id` | Central Ingestion Project ID | `string` | - | yes |
| `enable_cloud_asset_api` | Enable Cloud Asset API | `bool` | `true` | no |
| `enable_cloud_billing_api` | Enable Cloud Billing API | `bool` | `true` | no |
| `enable_recommender_api` | Enable Recommender API | `bool` | `true` | no |
| `enable_bigquery_reservation_api` | Enable BigQuery Reservation API | `bool` | `true` | no |
| `enable_cloud_run_admin_api` | Enable Cloud Run Admin API | `bool` | `true` | no |
| `enable_cloud_sql_admin_api` | Enable Cloud SQL Admin API | `bool` | `true` | no |
| `disable_apis_on_destroy` | Disable APIs when destroyed | `bool` | `false` | no |
| `nops_service_account_email` | Email address of the nOps service account to grant required IAM roles | `string` | `""` | no |
| `grant_nops_iam_roles` | Whether to grant organization-level IAM roles to the nOps service account | `bool` | `true` | no |

## Outputs

| Output | Description |
|--------|-------------|
| `central_ingestion_project_id` | The Central Ingestion Project ID |
| `enabled_apis_summary` | Summary of enabled APIs by project |
| `total_projects` | Total number of projects in the organization |
| `nops_iam_roles_granted` | List of organization-level IAM roles granted to the nOps service account |

## Finding Your Organization ID

To find your GCP Organization ID:

```bash
gcloud organizations list
```

Or via the GCP Console:
1. Go to [GCP Console](https://console.cloud.google.com/)
2. Select your organization
3. The Organization ID is shown in the URL or organization details

## Finding Your Central Ingestion Project ID

The `central_ingestion_project_id` is the GCP project ID where the Cloud Asset API and Cloud Billing API will be enabled. This should be a central/hub project that aggregates asset and billing data from other projects in your organization.

### What is a Central Ingestion Project?

A Central Ingestion Project is a dedicated GCP project that acts as a hub for:
- Collecting asset inventory data from all projects in your organization (via Cloud Asset API)
- Accessing billing information across your organization (via Cloud Billing API)

This project should be:
- An existing project in your organization (this module does not create projects)
- A project you have administrative access to
- A project where you want centralized asset and billing data collection

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
- **Project Name**: "nOps Central Hub"
- **Project ID**: `nops-central-hub-12345`
- **Project Number**: `123456789012`

You would use:
```hcl
central_ingestion_project_id = "nops-central-hub-12345"
```

## Permissions Required

The service account or user running this module needs:

- **Organization Level**:
  - `resourcemanager.organizations.get`
  - `resourcemanager.projects.list`
  - `resourcemanager.organizationIamPolicies.set` (required if granting nOps IAM roles)

- **Project Level** (for each project):
  - `serviceusage.services.enable`
  - `serviceusage.services.get`
  - `serviceusage.services.list`

You can grant these permissions by assigning one of these roles:
- `roles/serviceusage.serviceUsageAdmin` (recommended for API enablement)
- `roles/resourcemanager.organizationAdmin` (required for granting organization-level IAM roles)
- `roles/owner` (full access)

**Note:** If you're granting IAM roles to the nOps service account, you need organization-level IAM permissions (`roles/resourcemanager.organizationAdmin` or `roles/owner` at the organization level).

## Troubleshooting

### Error: "Permission denied"

Ensure your credentials have the required permissions listed above.

### Error: "Project not found"

Verify that:
- The `organization_id` is correct
- The `central_ingestion_project_id` exists and is accessible
- Your credentials have access to the organization

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

- The module uses `google_projects` data source which may have rate limits for large organizations
- API enablement is asynchronous; the module will wait for enablement to complete

## Support

For issues or questions, please contact nOps Support.


