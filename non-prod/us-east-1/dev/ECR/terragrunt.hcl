# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# We override the terraform block source attribute here just for the QA environment to show how you would deploy a
# different version of the module in a specific environment.
# Create a new ECR repository for the Lambda function code
terraform {
  source = "terraform-aws-modules/ecr/aws"
  version = "1.6.0"
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

# ---------------------------------------------------------------------------------------------------------------------
# We don't need to override any of the common parameters for this environment, so we don't specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name              =  local.environment_vars.locals.ecr_repository_name
  //repository_type = "public" by default private

  # Add the lifecycle policy
  enable_lifecycle_policy = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rule_priority = 1,
        selection = {
          count_type = "imageCountMoreThan"
          count_number = 1
          tag_status = "untagged"
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = local.environment_vars.locals.tags 

}