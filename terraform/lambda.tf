locals {
    environment_variables = {
        AWS_NODEJS_CONNECTION_REUSE_ENABLED = 1
        ENV = terraform.workspace
    }
}

