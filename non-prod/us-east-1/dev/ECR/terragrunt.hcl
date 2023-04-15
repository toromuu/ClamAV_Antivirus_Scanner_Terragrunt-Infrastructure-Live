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
# Create a new ECR repository for the Lambda function code
terraform {
  source = "terraform-aws-modules/ecr/aws"
  version = "2.15.0"
}

inputs = {
  name = "my-lambda-function"
}



# Build the Docker image
docker build -t my-lambda-function .

# Tag the image with the ECR repository URI
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker tag my-lambda-function:latest <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-lambda-function:latest

# Push the image to ECR
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-lambda-function:latest









FROM public.ecr.aws/lambda/nodejs:14

# Install ClamAV
RUN yum update -y && \
    yum install -y clamav clamd && \
    yum clean all

# Copy the Lambda function code
COPY index.js package.json /var/task/
RUN npm install --production

# Start the ClamAV daemon
CMD ["clamd"]