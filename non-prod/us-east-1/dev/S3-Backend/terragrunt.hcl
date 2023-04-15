# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "2.12.0"
}


# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/mysql.hcl"
  expose = true
}


# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

# Set the bucket name and other configuration options
inputs = {
  bucket_name = "my-bucket"
  acl = "private"
  versioning_enabled = true

  # Set the bucket notification configuration to trigger the Lambda function
  bucket_notification_lambda_function_configurations = [
    {
      lambda_function_arn = "${find_in_parent_folders("lambda_function/arn")}"
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = ""
      filter_suffix       = ""
    }
  ]
}