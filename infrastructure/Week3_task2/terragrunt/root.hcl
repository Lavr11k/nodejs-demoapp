locals {
  modules_path = "${get_repo_root()}/infrastructure/Week3_task2/modules"
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
    provider "aws" {
      profile = "private"
      region  = "eu-central-1"
    }
EOF
}
