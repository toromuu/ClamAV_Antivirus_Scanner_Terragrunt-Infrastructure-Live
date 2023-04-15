# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# We override the terraform block source attribute here just for the QA environment to show how you would deploy a
# different version of the module in a specific environment.
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v0.7.0"
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
# Set the function name, handler, and runtime
inputs = {
  function_name = "my-lambda-function"
  handler = "index.handler"
  runtime = "nodejs14.x"

  # Set the function code and dependencies
  image_uri = "${find_in_parent_folders("lambda_image/registry_id")}:latest"

  # Set the environment variables for ClamAV and the quarantine bucket
  environment_variables = {
    CLAMAV_DB_URL = "https://database.clamav.net"
    CLAMAV_DB_FILE = "daily.cvd"
    QUARANTINE_BUCKET = "${find_in_parent_folders("quarantine_bucket/bucket_id")}"
  }

  # Set the IAM role for the function to allow it to access S3 and write to the quarantine bucket
  execution_role_policy = data.aws_iam_policy_document.lambda_function_policy.json
}

# Set up an IAM policy document for the Lambda function to allow it to access S3 and write to the quarantine bucket
data "aws_iam_policy_document" "lambda_function_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "${find_in_parent_folders("s3_bucket/arn")}",
      "${find_in_parent_folders("quarantine_bucket/arn")}"
    ]
  }
}
