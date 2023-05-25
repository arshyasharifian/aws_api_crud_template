terraform {
    backend "s3" {
        # stores the s3 state file remotely for developers to work in parallel
        bucket = "<name_of_s3_bucket>"
        key = "<directory_to_store_state_file>/terraform.tfstate"
        workspace_key_prefix = ""
    }
}

provider "aws" {
  alias = "admin"
  assume_role {
    # create a role in your AWS account with admin permisions and list the arn
    role_arn = "<enter_admin_role>"
  }
}
