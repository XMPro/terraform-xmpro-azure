# =============================================================================
# STREAM HOST VALIDATION RULES
# =============================================================================
# This file contains centralized validation logic for the Stream Host example
# deployment to ensure proper configuration dependencies and catch configuration
# errors early during terraform plan operations.

# -----------------------------------------------------------------------------
# Application Insights Alerting Dependency Validation
# -----------------------------------------------------------------------------
# Validates that Application Insights is available when alerting is enabled
# Application Insights is required for alerting to function properly and can be
# provided either through internal monitoring or external configuration
resource "terraform_data" "app_insights_alerting_validation" {
  lifecycle {
    precondition {
      condition = !(var.enable_alerting == true && var.enable_monitoring == false && var.external_app_insights_id == null)
      error_message = <<-EOT
        When enable_alerting = true and enable_monitoring = false, external_app_insights_id must be provided.
        
        Current configuration:
          enable_alerting = ${var.enable_alerting}
          enable_monitoring = ${var.enable_monitoring}  
          external_app_insights_id = ${var.external_app_insights_id == null ? "null" : "provided"}
        
        Solution: Provide the external Application Insights resource ID:
          external_app_insights_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Insights/components/xxx"
        
        Alternative: Enable internal monitoring to create Application Insights automatically:
          enable_monitoring = true
      EOT
    }
  }
}