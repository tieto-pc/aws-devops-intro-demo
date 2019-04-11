# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").


##### Terraform configuration #####

# Usage:
# AWS_PROFILE=pc-demo terraform init
# AWS_PROFILE=pc-demo terraform get
# AWS_PROFILE=pc-demo terraform plan
# AWS_PROFILE=pc-demo terraform apply

# NOTE: If you want to create a separate version of this demo, use a unique prefix, e.g. "myname-demo".
# This way all entities have a different name and also you create a dedicate terraform state file
# (remember to call 'terraform destroy' once you are done with your experimentation).
# So, you have to change the prefix in both local below and terraform configuration section in key.


# NOTE: You cannot use locals in the terraform configuration since terraform
# configuration does not allow interpolation in the configuration section.
terraform {
  required_version = ">=0.11.13"
  backend "s3" {
    # NOTE: I use the same bucket for storing terraform statefiles for all PC demos (but different key).
    # NOTE AS specialists: You should create the S3 bucket and DynamoDB table as instructed in the README.md file and add the values here.
    bucket     = "tieto-pc-demos-terraform-backends"
    # NOTE: This must be unique for each Tieto PC demo!!!
    # Use the same prefix and dev as in local!
    # I.e. key = "<prefix>/<dev>/terraform.tfstate".
    key        = "aws-devops-intro-demo/dev/terraform.tfstate"
    region     = "eu-west-1"
    # NOTE: I use the same DynamoDB table for locking all state files of all demos. Do not change name.
    # NOTE AS specialists: You should create the S3 bucket and DynamoDB table as instructed in the README.md file and add the values here.
    dynamodb_table = "tieto-pc-demos-terraform-backends"
    # NOTE: This is AWS account profile, not env! You probably have two accounts: one dev (or test) and one prod.
    # NOTE AS specialists: you should provide here your own profile.
    profile    = "pc-demo"
  }
}


locals {
  # Ireland
  my_region                 = "eu-west-1"
  # Use unique environment names, e.g. dev, custqa, qa, test, perf, ci, prod...
  my_env                    = "dev"
  # Use consistent prefix, e.g. <cloud-provider>-<demo-target/purpose>-demo, e.g. aws-ecs-demo
  my_prefix                 = "devopsintro"
  # ECR Registry name to push the Docker image created in this demo.
  # We assume that it is in the same AWS account and the same region.
  my_ecr_docker_registry_name    = "aws-ecs-demo-dev-ecr-java-crm-demo"
  # We use the https://github.com/tieto-pc/java-simple-rest-demo-app as demo app
  my_docker_app_image_name       = "tieto-pc/java-devops-crm-demo"

}

provider "aws" {
  region     = "${local.my_region}"
}


# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source            = "../../modules/env-def"
  prefix            = "${local.my_prefix}"
  env               = "${local.my_env}"
  region            = "${local.my_region}"
  ecr_registry_name = "${local.my_ecr_docker_registry_name}"
  docker_app_image_name = "${local.my_docker_app_image_name}"

}

