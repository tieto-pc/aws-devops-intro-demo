# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.

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
}

# The Build DevOps tool.
module "codebuild" {
  source                  = "../codebuild"
  prefix                  = "${var.prefix}"
  env                     = "${var.env}"
  region                  = "${var.region}"
  codecommit_repo_http_url            = "${module.codecommit.codecommit_repo_http_url}"
  s3_cache_bucket                     = "${module.s3.s3_cache_bucket}"
  s3_cache_bucket_arn                 = "${module.s3.s3_cache_bucket_arn}"
  s3_artifact_bucket                  = "${module.s3.s3_artifact_bucket}"
  s3_artifact_bucket_arn              = "${module.s3.s3_artifact_bucket_arn}"
  s3_log_bucket                       = "${module.s3.s3_log_bucket}"
  s3_log_bucket_arn                   = "${module.s3.s3_log_bucket_arn}"
  cloudwatch_codebuild_log_group_name = "${module.cloudwatch_logs.cloudwatch_codebuild_log_group_name}"
}
