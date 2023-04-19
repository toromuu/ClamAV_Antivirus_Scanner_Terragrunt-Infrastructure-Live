# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# We override the terraform block source attribute here just for the QA environment to show how you would deploy a
# different version of the module in a specific environment.
terraform {
   source = "tfr:///terraform-aws-modules/lambda/aws//.?version=4.14.0"
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

dependency "ecr_repository" {
  config_path = "../ECR"

  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    repository_arn = "ecr-arn-2123"
  }
}

dependency "lambda_role" {
  config_path = "../IAM"

  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    iam_role_arn = "ecr-arn-2123"
  }
}

dependency "sns" {
  config_path = "../SNS"

  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    sns_topic_arn = "arn-topic-2123"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------
# Set the function name, handler, and runtime
inputs = {
  function_name = local.environment_vars.locals.lambda_antivirus_scanner_name
  //handler = "index.handler"
  package_type = "Image"
  runtime = "nodejs16.x"
  timeout          = 900
  memory_size      = 3008
  ephemeral_storage_size = 8096
  cloudwatch_logs_retention_in_days = 90
  create_package = false
  create_role = false

  # Set the function code and dependencies
  image_uri = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.environment_vars.locals.ecr_repository_name}:latest"

  # Set the environment variables for ClamAV and the quarantine bucket
  environment_variables = {
    S3_PRODUCTION_BUCKET = local.environment_vars.locals.s3_production_bucket_name
    SNS_ARN_TOPIC = dependency.sns.outputs.sns_topic_arn
  }

  #  allowed_triggers = {
  #    S3_BUCKET = {
  #      service    = "s3"
  #      source_arn = dependency.s3_quarantine_bucket.outputs.bucket_arn
  #    }
  #  }

  # Set the IAM role for the function to allow it to access S3 and write to the production bucket
  lambda_role = dependency.lambda_role.outputs.iam_role_arn
  tags = local.environment_vars.locals.tags
}

