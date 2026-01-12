# Configure domain restricted sharing org policy to allow nOps organization
# This is required for customers who have domain restricted sharing enabled
resource "google_org_policy_policy" "domain_restricted_sharing" {
  count  = var.enable_domain_restricted_sharing ? 1 : 0
  name   = "organizations/${var.organization_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "organizations/${var.organization_id}"

  lifecycle {
    precondition {
      condition     = var.nops_customer_id != ""
      error_message = "nops_customer_id is required when enable_domain_restricted_sharing is true. Find it in nOps → Organization Settings → GCP Integration"
    }
  }

  spec {
    rules {
      values {
        allowed_values = [
          var.nops_customer_id,
        ]
      }
    }
  }
}
