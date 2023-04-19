# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment                   = "dev"
  tags                          = { "Solution" : "S3_Antivirus_Scanner" }
  ecr_repository_name           = "clamav_antivirus_scanner_repository"
  lambda_antivirus_scanner_name = "clamav_antivirus_scanner_lambda"
  s3_production_bucket_name     = "production-clamav-antivirus-scanner-test"
  s3_quarantine_bucket_name     = "quarantine-clamav-antivirus-scanner-test"
  admins_pdl = [
    "diegotoro1998@gmail.com",
    "diegoalejandrotoro@hotmail.com",
    "datorram@posgrado.upv.es"
  ]
  sns_topic_name = "emailtoAdmins"
}
