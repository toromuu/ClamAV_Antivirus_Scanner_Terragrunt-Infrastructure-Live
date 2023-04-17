# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "dev"
  tags        = { "Solution" : "S3_Antivirus_Scanner" }
  ecr_repository_name = "ClamAV_Antivirus_Scanner_Repository"
}
