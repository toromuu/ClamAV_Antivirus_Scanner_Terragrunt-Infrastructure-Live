# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  source = "../../../../..//modules/s3_with_notifications"
}


# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include {
  path = find_in_parent_folders()
}

# Include the necessary variables
locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
}

dependency "lambda_scanner" {
  config_path = "../../Lambda"

  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    lambda_function_arn = "lambda-arn-2123"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

# Set the bucket name and other configuration options
inputs = {

  bucket_name         = local.environment_vars.locals.s3_quarantine_bucket_name
  acl                 = "private"
  versioning_enabled  = true
  create_notification = true
  //notification_lambda_function_arn = "arn:aws:lambda:${local.aws_region}:${local.account_id}:function:${local.environment_vars.locals.lambda_antivirus_scanner_name}"
  notification_lambda_function_name = local.environment_vars.locals.lambda_antivirus_scanner_name
  notification_lambda_function_arn  = dependency.lambda_scanner.outputs.lambda_function_arn
  create_lifecycle_configuration    = true
  lifecycle_expiration_days         = 7
  tags                              = local.environment_vars.locals.tags


}