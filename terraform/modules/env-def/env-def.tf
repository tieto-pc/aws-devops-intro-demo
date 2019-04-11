# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.

# CodeBuild policy needs aws account id for ecr registry.
data "aws_caller_identity" "current" {}


# S3 buckets needed by Codebuild.
module "s3" {
  source          = "../s3"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  region          = "${var.region}"
}

# Cloudwatch log group.
module "cloudwatch_logs" {
  source          = "../cloudwatch-logs"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  region          = "${var.region}"
}


# The Git code repository.
module "codecommit" {
  source          = "../codecommit"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  region          = "${var.region}"
  codepipeline_project_arn  = "${module.codepipeline.codepipeline_project_arn}"
}

# The Build DevOps tool.
module "codebuild" {
  source                  = "../codebuild"
  prefix                  = "${var.prefix}"
  env                     = "${var.env}"
  region                  = "${var.region}"
  codecommit_repo_http_url            = "${module.codecommit.codecommit_repo_http_url}"
  codecommit_repo_arn                 = "${module.codecommit.codecommit_repo_arn}"
  s3_cache_bucket                     = "${module.s3.s3_cache_bucket}"
  s3_cache_bucket_arn                 = "${module.s3.s3_cache_bucket_arn}"
  s3_artifact_bucket                  = "${module.s3.s3_artifact_bucket}"
  s3_artifact_bucket_arn              = "${module.s3.s3_artifact_bucket_arn}"
  s3_log_bucket                       = "${module.s3.s3_log_bucket}"
  s3_log_bucket_arn                   = "${module.s3.s3_log_bucket_arn}"
  cloudwatch_codebuild_log_group_name = "${module.cloudwatch_logs.cloudwatch_codebuild_log_group_name}"
  ecr_registry_name                   = "${var.ecr_registry_name}"
  aws_account_id                      = "${data.aws_caller_identity.current.account_id}"
  docker_app_image_name               = "${var.docker_app_image_name}"
}


# The Pipeline DevOps tool.
module "codepipeline" {
  source                  = "../codepipeline"
  prefix                  = "${var.prefix}"
  env                     = "${var.env}"
  region                  = "${var.region}"
  codecommit_repo_arn                   = "${module.codecommit.codecommit_repo_arn}"
  s3_cache_bucket                       = "${module.s3.s3_cache_bucket}"
  s3_cache_bucket_arn                   = "${module.s3.s3_cache_bucket_arn}"
  s3_artifact_bucket                    = "${module.s3.s3_artifact_bucket}"
  s3_artifact_bucket_arn                = "${module.s3.s3_artifact_bucket_arn}"
  s3_log_bucket                         = "${module.s3.s3_log_bucket}"
  s3_log_bucket_arn                     = "${module.s3.s3_log_bucket_arn}"
  cloudwatch_codebuild_log_group_name   = "${module.cloudwatch_logs.cloudwatch_codebuild_log_group_name}"
  codecommit_repo_name                  = "${module.codecommit.codecommit_repo_name}"
  codebuild_build_and_test_project_arn  = "${module.codebuild.codebuild_build_and_test_project_arn}"
  codebuild_build_and_test_project_name = "${module.codebuild.codebuild_build_and_test_project_name}"
  codebuild_build_docker_image_project_arn  = "${module.codebuild.codebuild_build_docker_image_project_arn}"
  codebuild_build_docker_image_project_name = "${module.codebuild.codebuild_build_docker_image_project_name}"
}
