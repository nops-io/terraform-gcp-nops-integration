# GCP nOps Integration Terraform Module

This Terraform/OpenTofu module simplifies the integration of nOps with your GCP organization by automatically:
- **Enabling all required GCP APIs** across your organization
- **Granting organization-level IAM roles** to your nOps service account
- **Granting billing account-level IAM roles** to your nOps service account

With just 4 required variables, you can get up and running quickly. All APIs are always enabled, and all IAM roles are granted by default for the simplest possible experience.

## Module Structure

The module code is organized into separate files:
- **`apis.tf`** - Contains all GCP API enablement resources
- **`organization_iam.tf`** - Contains all organization-level IAM role resources
- **`billing_account_iam.tf`** - Contains all billing account-level IAM role resources
- **`main.tf`** - Contains shared data sources and local values (Terraform configuration, organization projects data source)

## Overview

This module automatically enables the following APIs across your organization:

| API Service | API Service ID | Scope |
|------------|----------------|-------|
| Cloud Asset API | `cloudasset.googleapis.com` | Central Ingestion Project |
| Cloud Billing API | `cloudbilling.googleapis.com` | Central Ingestion Project |
| Recommender API | `recommender.googleapis.com` | All projects (scoped to billing account) |
| BigQuery Reservation API | `bigqueryreservation.googleapis.com` | All projects |
| Cloud Run Admin API | `run.googleapis.com` | All projects |
| Cloud SQL Admin API | `sqladmin.googleapis.com` | All projects |

**All APIs are always enabled** - no configuration needed. Simply provide your organization ID and central ingestion project ID.

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

# Simple module invocation - enables all APIs and grants all IAM roles
# All APIs are automatically enabled:
# - Cloud Asset API (Central Ingestion Project)
# - Cloud Billing API (Central Ingestion Project)
# - Recommender API (all projects)
# - BigQuery Reservation API (all projects)
# - Cloud Run Admin API (all projects)
# - Cloud SQL Admin API (all projects)
#
# All IAM roles are automatically granted (defaults to true):
# - Organization-level IAM roles (requires nops_service_account_email)
# - Billing account-level IAM roles (requires nops_service_account_email and billing_account_id)
module "nops_gcp_integration" {
  source = "./nops-gcp-module"  # or use git URL
  
  # Required: Organization and project information
  organization_id            = "123456789012"  # Replace with your GCP Organization ID
  central_ingestion_project_id = "my-central-project-id"  # Replace with your central project ID
  
  # Required: nOps service account information for IAM roles
  nops_service_account_email = "your-nops-sa@project.iam.gserviceaccount.com"
  billing_account_id = "XXXXXX-XXXXXX-XXXXXX"  # Replace with your Billing Account ID
  
  # Optional: All IAM roles are granted by default (set to false to disable)
  # grant_nops_iam_roles = true         # Organization-level roles (default: true)
  # grant_nops_billing_iam_roles = true # Billing account roles (default: true)
  
  # Optional: Disable APIs when module is destroyed (default: false)
  # disable_apis_on_destroy = false
}

# Outputs
output "api_enablement_summary" {
  description = "Summary of enabled APIs by project"
  value = module.nops_gcp_integration.enabled_apis_summary
}

output "total_projects" {
  description = "Total number of projects in the organization"
  value = module.nops_gcp_integration.total_projects
}

output "nops_iam_roles_granted" {
  description = "List of organization-level IAM roles granted"
  value = module.nops_gcp_integration.nops_iam_roles_granted
}

output "nops_billing_iam_roles_granted" {
  description = "List of billing account-level IAM roles granted"
  value = module.nops_gcp_integration.nops_billing_iam_roles_granted
}
```

That's it! With just 4 required variables, this module will:
- ✅ Enable all required GCP APIs across your organization
- ✅ Grant organization-level IAM roles to your nOps service account
- ✅ Grant billing account-level IAM roles to your nOps service account
```

### What Gets Enabled and Granted

**APIs Enabled (automatically, no configuration needed):**
- Cloud Asset API (Central Ingestion Project)
- Cloud Billing API (Central Ingestion Project)
- Recommender API (all projects)
- BigQuery Reservation API (all projects)
- Cloud Run Admin API (all projects)
- Cloud SQL Admin API (all projects)

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
| `organization_id` | GCP Organization ID | `string` | - | yes |
| `central_ingestion_project_id` | Central Ingestion Project ID | `string` | - | yes |
| `disable_apis_on_destroy` | Disable APIs when destroyed | `bool` | `false` | no |
| `nops_service_account_email` | Email address of the nOps service account to grant required IAM roles | `string` | `""` | no |
| `grant_nops_iam_roles` | Whether to grant organization-level IAM roles to the nOps service account | `bool` | `true` | no |
| `billing_account_id` | The GCP Billing Account ID to grant billing viewer role. Required if grant_nops_billing_iam_roles is true | `string` | `""` | no |
| `grant_nops_billing_iam_roles` | Whether to grant billing account-level IAM roles (billing.viewer) to the nOps service account | `bool` | `true` | no |

## Outputs

| Output | Description |
|--------|-------------|
| `central_ingestion_project_id` | The Central Ingestion Project ID |
| `enabled_apis_summary` | Summary of enabled APIs by project |
| `total_projects` | Total number of projects in the organization |
| `nops_iam_roles_granted` | List of organization-level IAM roles granted to the nOps service account |
| `nops_billing_iam_roles_granted` | List of billing account-level IAM roles granted to the nOps service account |

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

## Permissions Required

The service account or user running this module needs:

- **Organization Level**:
  - `resourcemanager.organizations.get`
  - `resourcemanager.projects.list`
  - `resourcemanager.organizationIamPolicies.set` (required if granting organization-level IAM roles)

- **Billing Account Level**:
  - `billing.accounts.getIamPolicy` (required to read billing account IAM policy)
  - `billing.accounts.setIamPolicy` (required if granting billing account-level IAM roles)

- **Project Level** (for each project):
  - `serviceusage.services.enable`
  - `serviceusage.services.get`
  - `serviceusage.services.list`

You can grant these permissions by assigning one of these roles:
- `roles/serviceusage.serviceUsageAdmin` (recommended for API enablement)
- `roles/resourcemanager.organizationAdmin` (required for granting organization-level IAM roles)
- `roles/billing.admin` (required for granting billing account-level IAM roles)
- `roles/owner` (full access)

**Note:** 
- If you're granting organization-level IAM roles to the nOps service account, you need organization-level IAM permissions (`roles/resourcemanager.organizationAdmin` or `roles/owner` at the organization level).
- If you're granting billing account-level IAM roles, you need billing account permissions (`roles/billing.admin` or `roles/owner` on the billing account).

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


