locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env  = "${var.prefix}-${var.env}"
}

# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codebuild_project.html


# Not using any vpc as in the original example.
# Mostly using values from the manually created CodeBuild that I used to validate a working configuration.
# See README.md.
# Builds and tests the Java project.
resource "aws_codebuild_project" "codebuild_build_and_test_project" {
  name          = "${local.my_name}-project"
  description   = "CodeBuild demo project"
  build_timeout = "5"
  service_role  = "${var.service_role_arn}"
  badge_enabled = "false"

  source {
    type            = "CODECOMMIT"
    location        = "${var.codecommit_repo_http_url}"
    git_clone_depth = "1"
    buildspec       = "buildspec.yml"
    insecure_ssl    = "false"
  }

  # We let CodePipeline to push the artifact to S3.
  artifacts {
    type                = "NO_ARTIFACTS"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:1.0-1.8.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = "false"
  }

  cache {
    type     = "S3"
    location = "${var.s3_cache_bucket}"
  }

  # Terraform does not expose logsConfig part, see: https://github.com/terraform-providers/terraform-provider-aws/issues/6312

  tags {
    Name        = "${local.my_name}-codebuild-project"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# TODO: resource "aws_codebuild_project" "codebuild_bake_docker_image_project" {
